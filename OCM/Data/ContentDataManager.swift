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
typealias MenusResponseBlock = (Result<[Menu], OCMRequestError>, Bool) -> Void

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

//swiftlint:disable type_body_length

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
    private var currentContentListRequestDownloading: (request: Request, completions: [ContentListResponseBlock])?
    private var currentMenuRequestDownloading: (request: Request, completions: [MenusResponseBlock])?
    private var actionsCache: JSON?
    
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
    
    func loadMenus(forcingDownload force: Bool = false, completion: @escaping (Result<[Menu], OCMRequestError>, Bool) -> Void) {
        self.contentCacheManager.initializeCache()
        
        switch self.loadDataSourceForMenus(forcingDownload: force) {
        case .fromNetwork:
            if self.currentMenuRequestDownloading == nil {
                let request = self.menuService.getMenus { result in
                    switch result {
                    case .success(let JSON):
                        guard
                            let jsonMenu = JSON["menus"],
                            let menus = try? jsonMenu.flatMap(Menu.menuList)
                            else {
                                let error = OCMRequestError(error: .unexpectedError(), status: .unknownError)
                                completion(.error(error), false)
                                return
                        }
                        if !self.offlineSupport {
                            // Clean database every menus download when we have offlineSupport disabled
                            ContentCoreDataPersister.shared.cleanDataBase()
                            ContentCacheManager.shared.resetCache()
                        }
                        self.saveMenusAndSections(from: JSON)
                        self.currentMenuRequestDownloading?.completions.forEach { $0(.success(menus), false) }
                    case .error(let error):
                        self.currentMenuRequestDownloading?.completions.forEach { $0(.error(error), false) }
                    }
                    self.currentMenuRequestDownloading = nil
                }
                self.currentMenuRequestDownloading = (request: request, completions: [completion])
            } else {
                self.currentMenuRequestDownloading?.completions.append(completion)
            }
        case .fromCache(let menus):
            completion(.success(menus), true)
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
            self.contentCacheManager.startCaching(section: path)
            completion(.success(content))
        }
    }
    
    func loadContentList(forcingDownload force: Bool = false, matchingString searchString: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
        self.contentListService.getContentList(matchingString: searchString) { result in
            switch result {
            case .success(let json):
                guard let contentList = try? ContentList.contentList(json)
                    else { return completion(.error(.unexpectedError())) }
                self.appendElementsCache(elements: json["elementsCache"])
                completion(.success(contentList))
            case .error(let error):
                completion(.error(error as NSError))
            }
        }
    }
    
    func cancelAllRequests() {
        self.currentMenuRequestDownloading?.request.cancel() // Cancel the current request
        self.currentContentListRequestDownloading?.request.cancel() // Cancel the current request
        self.enqueuedRequests.forEach { $0.completion(.error(NSError.unexpectedError())) } // Cancel all content list enqueued requests
        self.enqueuedRequests = [] // Delete all requests in array
    }
    
    // MARK: - Private methods
    
    private func appendElementsCache(elements: JSON?) {
        guard var currentElements = self.actionsCache?.toDictionary() else {
            self.actionsCache = elements
            return
        }
        guard let newElements = elements?.toDictionary() else { return }
        for (key, value) in newElements {
            currentElements.updateValue(value, forKey: key)
        }
        self.actionsCache = JSON(from: currentElements)
    }
    
    private func saveMenusAndSections(from json: JSON) {
        guard
            let menuJson = json["menus"]
        else {
            return
        }
        
        let menus = menuJson.flatMap { try? Menu.menuList($0) }
        self.contentPersister.save(menus: menus)
        var sectionsMenu: [[String]] = []
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
            sectionsMenu.append(sections)
        }
        if self.offlineSupport {
            // Cache sections
            // In order to prevent errors with multiple menus, we are only caching the images from the menu with more sections
            let sortSections = sectionsMenu.sorted(by: { $0.count > $1.count })
            if sortSections.indices.contains(0) {
                self.contentCacheManager.cache(sections: sortSections[0])
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
        let requestWithSamePath = self.enqueuedRequests.flatMap({ $0.path == path ? $0 : nil })
        let completions = requestWithSamePath.map({ $0.completion })
        let request = self.contentListService.getContentList(with: path) { result in
            let completions = self.currentContentListRequestDownloading?.completions
            switch result {
            case .success(let json):
                guard let contentList = try? ContentList.contentList(json) else {
                    completions?.forEach { $0(.error(NSError.unexpectedError())) }
                    return
                }
                self.saveContentAndActions(from: json, in: path)
                if self.offlineSupport {
                    // Cache contents and actions
                    self.contentCacheManager.cache(contents: contentList.contents, with: path) {
                        completions?.forEach { $0(.success(contentList)) }
                    }
                } else {
                    completions?.forEach { $0(.success(contentList)) }
                }
            case .error(let error):
                completions?.forEach { $0(.error(error as NSError)) }
            }
            self.removeRequest(for: path)
            self.performNextRequest()
        }
        self.currentContentListRequestDownloading = (request: request, completions: completions)
    }
    
    // MARK: - Enqueued request manager methods
    
    private func addRequestToQueue(_ request: ContentListRequest) {
        self.enqueuedRequests.append(request)
        // If there is a download with the same path, append the completion block in order to return the same data
        if self.currentContentListRequestDownloading?.request.endpoint == request.path {
            self.currentContentListRequestDownloading?.completions.append(request.completion)
        }
    }
    
    private func removeRequest(for path: String) {
        self.enqueuedRequests = self.enqueuedRequests.flatMap({ $0.path == path ? nil : $0 })
        self.currentContentListRequestDownloading = nil
    }
    
    private func performNextRequest() {
        if self.enqueuedRequests.count > 0 {
            if self.currentContentListRequestDownloading == nil {
                let next = self.enqueuedRequests[0]
                self.requestContentList(with: next.path)
            }
        } else {
            if self.offlineSupport {
                // Start caching when all content is downloaded
                self.contentCacheManager.startCaching()
            }
        }
    }
    
    // MARK: - Data source methods
    
    /// The Menu Data Source. It is fromCache when offlineSupport is enabled and we have it in db. When we force the 
    /// download, it checks internet and return cached data if there isn't internet connection.
    ///
    /// - Parameter force: If the request wants to force the download
    /// - Returns: The data source
    private func loadDataSourceForMenus(forcingDownload force: Bool) -> DataSource<[Menu]> {
        let cachedMenu = self.cachedMenus()
        if self.offlineSupport {
            if self.reachability.isReachable() {
                if force {
                    return .fromNetwork
                } else {
                    if cachedMenu.isEmpty {
                        return .fromNetwork
                    } else {
                        return .fromCache(cachedMenu)
                    }
                }
                
            } else if cachedMenu.count != 0 {
                return .fromCache(cachedMenu)
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
        guard let memoryCachedJson = self.actionsCache?[url] else { return self.contentPersister.loadAction(with: url) }
        return ActionFactory.action(from: memoryCachedJson) ?? self.contentPersister.loadAction(with: url)
    }    
}

//swiftlint:enable type_body_length
