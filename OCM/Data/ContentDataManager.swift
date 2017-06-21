//
//  ContentDataManager.swift
//  OCM
//
//  Created by José Estela on 14/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import Reachability

enum DataSource<T> {
    case fromNetwork
    case fromCache(T)
}

struct ContentDataManager {
    
    // MARK: - Attributes
    
    let contentPersister: ContentPersister
    let menuService: MenuService
    let elementService: ElementService
    let contentListService: ContentListServiceProtocol
    let contentCacheManager: ContentCacheManager
    
    // MARK: - Default instance method
    
    static func defaultDataManager() -> ContentDataManager {
        return ContentDataManager(
            contentPersister: ContentCoreDataPersister.shared,
            menuService: MenuService(),
            elementService: ElementService(),
            contentListService: ContentListService(),
            contentCacheManager: ContentCacheManager.shared
        )
    }
    
    // MARK: - Methods
    
    func loadMenus(forcingDownload force: Bool = false, completion: @escaping (Result<[Menu], OCMRequestError>) -> Void) {
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
                    self.saveMenusAndSections(from: JSON)
                    completion(.success(menus))
                case .error(let error):
                    completion(.error(error))
                }
            }
        case .fromCache(let menus):
            // TODO: Cache manager needs to bootstrap 666 !!!
            self.contentCacheManager.initializeCache()
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
            self.contentListService.getContentList(with: path) { result in
                switch result {
                case .success(let json):
                    guard let contentList = try? ContentList.contentList(json) else { return completion(.error(.unexpectedError())) }
                    self.saveContentAndActions(from: json, in: path)
                    // Cache contents and actions
                    self.contentCacheManager.cache(contents: contentList.contents, with: path)
                    completion(.success(contentList))
                case .error(let error):
                    completion(.error(error as NSError))
                }
            }
        case .fromCache(let content):
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
            // Cache sections !!!
            self.contentCacheManager.cache(sections: sections)
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
    
    // MARK: - LoadStatus methods
    
    private func loadDataSourceForMenus(forcingDownload force: Bool) -> DataSource<[Menu]> {
        if isInternetEnabled() {
            return .fromNetwork
        } else if self.cachedMenus().count != 0 {
            return .fromCache(self.cachedMenus())
        }
        return .fromNetwork
    }
    
    private func loadDataSourceForElement(forcingDownload force: Bool, with identifier: String) -> DataSource<Action> {
        let action = self.cachedAction(from: identifier)
        if isInternetEnabled() {
            if force || action == nil {
                return .fromNetwork
            } else if let action = action {
                return .fromCache(action)
            }
        } else if let action = action {
            return .fromCache(action)
        }
        return .fromNetwork
    }
    
    private func loadDataSourceForContent(forcingDownload force: Bool, with path: String) -> DataSource<ContentList> {
        let content = self.cachedContent(with: path)
        if isInternetEnabled() {
            if force || content == nil {
                return .fromNetwork
            } else if let content = content {
                return .fromCache(content)
            }
        } else if let content = content {
            return .fromCache(content)
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
    
    // MARK: - Helpers
    
    private func isInternetEnabled() -> Bool {
        guard let status = Reachability()?.currentReachabilityStatus else { return true }
        return status != .notReachable
    }
}
