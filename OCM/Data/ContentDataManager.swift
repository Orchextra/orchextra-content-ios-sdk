//
//  ContentDataManager.swift
//  OCM
//
//  Created by José Estela on 14/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

typealias ContentListResponseBlock = (Result<ContentList, NSError>) -> Void

enum DataSource<T> {
    case fromNetwork
    case fromCache(T)
}

class ContentListRequest {
    
    let path: String
    let completion: ContentListResponseBlock
    
    init(path: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
        self.path = path
        self.completion = completion
    }
}

class ContentDataManager {
    
    // MARK: - Attributes
    
    static let sharedDataManager: ContentDataManager = defaultDataManager()

    let contentPersister: ContentPersister
    let menuService: MenuService
    let elementService: ElementService
    let contentListService: ContentListServiceProtocol
    let contentCacheManager: ContentCacheManager
    let offlineSupport: Bool
    let reachability: ReachabilityWrapper
    
    // MARK: - Private attributes
    
    private var enqueuedRequests: [ContentListRequest] = []
    private var currentRequestDownloading: (path: String, completions: [ContentListResponseBlock])?
    
    // MARK: - Init method
    
    init(contentPersister: ContentPersister,
         menuService: MenuService,
         elementService: ElementService,
         contentListService: ContentListServiceProtocol,
         contentCacheManager: ContentCacheManager,
         offlineSupport: Bool,
         reachability: ReachabilityWrapper) {
        self.contentPersister = contentPersister
        self.menuService = menuService
        self.elementService = elementService
        self.contentListService = contentListService
        self.contentCacheManager = contentCacheManager
        self.offlineSupport = offlineSupport
        self.reachability = reachability
    }
    
    // MARK: - Default instance method
    
    static func defaultDataManager() -> ContentDataManager {
        return ContentDataManager(
            contentPersister: ContentCoreDataPersister.shared,
            menuService: MenuService(),
            elementService: ElementService(),
            contentListService: ContentListService(),
            contentCacheManager: ContentCacheManager.shared,
            offlineSupport: Config.offlineSupport,
            reachability: ReachabilityWrapper.shared
        )
    }
    
    // MARK: - Methods
    
    func loadMenus(forcingDownload force: Bool = false, completion: @escaping (Result<[Menu], OCMRequestError>) -> Void) {
        self.contentCacheManager.initializeCache()
        
        switch self.loadDataSourceForMenus(forcingDownload: force) {
        case .fromNetwork:
            self.menuService.getMenus { result in
                switch result {
                case .success(let JSON):
                    guard
                        let jsonMenu = JSON["menus"],
                        let menus = try? jsonMenu.flatMap(Menu.menuList)
                        else {
                            completion(.error(OCMRequestError(error: .unexpectedError(), status: .unknownError)))
                            return
                    }
                    if !self.offlineSupport {
                        // Clean database every menus download when we have offlineSupport disabled
                        OCM.shared.resetCache()
                    }
                    self.saveMenusAndSections(from: JSON)
                    completion(.success(menus))
                case .error(let error):
                    completion(.error(error))
                }
            }
        case .fromCache(let menus):
            completion(.success(menus))
        }
    }
    
    func loadElement(forcingDownload force: Bool = false, with identifier: String, completion: @escaping (Result<Action, NSError>) -> Void) {
        switch self.loadDataSourceForElement(forcingDownload: force, with: identifier) {
        case .fromNetwork:
            self.elementService.getElement(with: identifier, completion: { result in
                switch result {
                case .success(let action):
                    completion(.success(action))
                case .error(let error):
                    completion(.error(error))
                }
            })
        case .fromCache(let action):
            completion(.success(action))
        }
    }
    
    func loadContentList(forcingDownload force: Bool = false, with path: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
        switch self.loadDataSourceForContent(forcingDownload: force, with: path) {
        case .fromNetwork:
            let request = ContentListRequest(path: path, completion: completion)
            self.addRequestToQueue(request)
            self.performNextRequest()
        case .fromCache(let content):
            // TODO: Initialize cache ???
            completion(.success(content))
        }
    }
    
    func loadContentList(forcingDownload force: Bool = false, matchingString searchString: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
        // What happend with this case? It is important to know that now there are not persisting the data returned
        self.contentListService.getContentList(matchingString: searchString) { result in
            switch result {
            case .success(let json):
                guard let contentList = try? ContentList.contentList(json)
                    else { return completion(.error(.unexpectedError())) }
                completion(.success(contentList))
            case .error(let error):
                completion(.error(error as NSError))
            }
        }
    }
    
    // MARK: - Private methods
    
    private func saveMenusAndSections(from json: JSON) {
        guard
            let menuJson = json["menus"]
        else {
            return
        }
        
        let menus = menuJson.flatMap { try? Menu.menuList($0) }
        self.contentPersister.save(menus: menus)
        for menu in menuJson {
            guard
                let menuModel = try? Menu.menuList(menu),
                let elements = menu["elements"]?.toArray() as? [NSDictionary],
                let elementsCache = json["elementsCache"]
            else {
                return
            }
            // Sections to cache
            var sections = [String]()
            // Save sections in menu
            let jsonElements = elements.map({ JSON(from: $0) })
            self.contentPersister.save(sections: jsonElements, in: menuModel.slug)
            for element in jsonElements {
                if let elementUrl = element["elementUrl"]?.toString(),
                    let elementCache = elementsCache["\(elementUrl)"] {
                    // Save each action in section
                    self.contentPersister.save(action: elementCache, in: elementUrl)
                    if let sectionPath = elementCache["render"]?["contentUrl"]?.toString() {
                        sections.append(sectionPath)
                    }
                }
            }
            if self.offlineSupport {
                // Cache sections !!!
                self.contentCacheManager.cache(sections: sections)
            }
        }
    }
    
    private func saveContentAndActions(from json: JSON, in path: String) {
        // Save content in path
        self.contentPersister.save(content: json, in: path)
        if let elementsCache = json["elementsCache"]?.toDictionary() {
            for (identifier, action) in elementsCache {
                // Save each action linked to content path
                self.contentPersister.save(action: JSON(from: action), with: identifier, in: path)
            }
        }
    }
    
    private func requestContentList(with path: String) {
        self.contentListService.getContentList(with: path) { result in
            let completions = self.currentRequestDownloading?.completions
            switch result {
            case .success(let json):
                guard
                    let contentList = try? ContentList.contentList(json)
                else {
                    _ = completions?.map({ $0(.error(NSError.unexpectedError())) })
                    return
                }
                self.saveContentAndActions(from: json, in: path)
                if self.offlineSupport {
                    // Cache contents and actions
                    self.contentCacheManager.cache(contents: contentList.contents, with: path)
                }
                _ = completions?.map({ $0(.success(contentList)) })
            case .error(let error):
                _ = completions?.map({ $0(.error(error as NSError)) })
            }
            self.removeRequest(for: path)
            self.performNextRequest()
        }
    }
    
    // MARK: - Enqueued request manager methods
    
    private func addRequestToQueue(_ request: ContentListRequest) {
        self.enqueuedRequests.append(request)
        // If there is a download with the same path, append the completion block in order to return the same data
        if self.currentRequestDownloading?.path == request.path {
            self.currentRequestDownloading?.completions.append(request.completion)
        }
    }
    
    private func removeRequest(for path: String) {
        self.enqueuedRequests = self.enqueuedRequests.flatMap({ $0.path == path ? nil : $0 })
        self.currentRequestDownloading = nil
    }
    
    private func performNextRequest() {
        if self.enqueuedRequests.count > 0 {
            if self.currentRequestDownloading == nil {
                let next = self.enqueuedRequests[0]
                let requestWithSamePath = self.enqueuedRequests.flatMap({ $0.path == next.path ? $0 : nil })
                let completions = requestWithSamePath.map({ $0.completion })
                self.currentRequestDownloading = (next.path, completions)
                self.requestContentList(with: next.path)
            }
        } else {
            if self.offlineSupport {
                // Start caching when all content is downloaded
                self.contentCacheManager.startCaching()
            }
        }
    }
    
    // MARK: - LoadStatus methods
    
    /// The Menu Data Source. It is fromCache only when offlineSupport is enabled and there are menus in db
    ///
    /// - Parameter force: If the request wants to force the download
    /// - Returns: The data source
    private func loadDataSourceForMenus(forcingDownload force: Bool) -> DataSource<[Menu]> {
        if self.offlineSupport {
            if self.reachability.isReachable() {
                return .fromNetwork
            } else if self.cachedMenus().count != 0 {
                return .fromCache(self.cachedMenus())
            }
        }
        return .fromNetwork
    }
    
    
    /// The Element Data Source. It is fromCache when it is in db (offlineSupport doesn't matter here, we always save actions info and try to get it from cache). When we force the download, it checks internet and return cached data if there isn't internet connection.
    ///
    /// - Parameters:
    ///   - force: If the request wants to force the download
    ///   - identifier: The identifier of the element
    /// - Returns: The data source
    private func loadDataSourceForElement(forcingDownload force: Bool, with identifier: String) -> DataSource<Action> {
        let action = self.cachedAction(from: identifier)
        if self.offlineSupport {
            if self.reachability.isReachable() {
                if force || action == nil {
                    return .fromNetwork
                } else if let action = action {
                    return .fromCache(action)
                }
            } else if let action = action {
                return .fromCache(action)
            }
        } else if let action = action {
            return .fromCache(action)
        }
        return .fromNetwork
    }
    
    /// The Content Data Source. It is fromCache when offlineSupport is disabled and we have it in db. When we force the download, it checks internet and return cached data if there isn't internet connection.
    ///
    /// - Parameters:
    ///   - force: If the request wants to force the download
    ///   - path: The path of the content
    /// - Returns: The data source
    private func loadDataSourceForContent(forcingDownload force: Bool, with path: String) -> DataSource<ContentList> {
        if self.offlineSupport {
            let content = self.cachedContent(with: path)
            if self.reachability.isReachable() {
                if force || content == nil {
                    return .fromNetwork
                } else if let content = content {
                    return .fromCache(content)
                }
            } else if let content = content {
                return .fromCache(content)
            }
        }
        return .fromNetwork
    }
    
    // MARK: - Fetch from cache
    
    private func cachedMenus() -> [Menu] {
        return self.contentPersister.loadMenus()
    }
    
    private func cachedContent(with path: String) -> ContentList? {
        return self.contentPersister.loadContent(with: path)
    }
    
    private func cachedAction(from url: String) -> Action? {
        return self.contentPersister.loadAction(with: url)
    }
    
}
