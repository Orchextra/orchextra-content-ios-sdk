//
//  ContentDataManager.swift
//  OCM
//
//  Created by José Estela on 14/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ContentDataManager {
    
    // MARK: - Attributes
    
    let contentPersister: ContentPersister
    let menuService: MenuService
    let elementService: ElementService
    let contentListService: ContentListServiceProtocol
    //!!! 666 ???
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
    
    func loadMenus(forcingDownload force: Bool = true, completion: @escaping (Result<[Menu], OCMRequestError>) -> Void) {
        if force || self.cachedMenus().count == 0 {
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
        } else {
            completion(.success(self.cachedMenus()))
        }
    }
    
    func loadElement(forcingDownload force: Bool = false, with identifier: String, completion: @escaping (Result<Action, NSError>) -> Void) {
        let action = self.cachedAction(from: identifier)
        if force || action == nil {
            self.elementService.getElement(with: identifier, completion: { result in
                switch result {
                case .success(let action):
                    completion(.success(action))
                case .error(let error):
                    completion(.error(error))
                }
            })
        } else if let action = action {
            completion(.success(action))
        } else {
            completion(.error(.unexpectedError()))
        }
    }
        
    func loadContentList(forcingDownload force: Bool = false, with path: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
        let content = self.contentPersister.loadContent(with: path)
        if force || content == nil {
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
        } else if let content = content {
            completion(.success(content))
        } else {
            completion(.error(.unexpectedError()))
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
        for menu in menuJson {
            guard
                let menuModel = try? Menu.menuList(menu),
                let elements = menu["elements"],
                let elementsCache = json["elementsCache"]
            else {
                return
            }
            // Save the menu
            self.contentPersister.save(menu: menuModel)
            // Sections to cache
            var sections = [String]()
            for element in elements {
                // Save each section in menu
                self.contentPersister.save(section: element, in: menuModel.slug)
                if let elementUrl = element["elementUrl"]?.toString(),
                    let elementCache = elementsCache["\(elementUrl)"] {
                    // Save each action in section
                    self.contentPersister.save(action: elementCache, in: elementUrl)
                    if let sectionPath = elementCache["render"]?["contentUrl"]?.toString() {
                        sections.append(sectionPath)
                    }
                }
            }
            // Cache sections
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
