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
    
    // MARK: - Default instance method
    
    static func defaultDataManager() -> ContentDataManager {
        return ContentDataManager(
            contentPersister: ContentCoreDataPersister.shared,
            menuService: MenuService(),
            elementService: ElementService(),
            contentListService: ContentListService()
        )
    }
    
    // MARK: - Methods
    
    func loadMenus(completion: @escaping (Result<[Menu], OCMRequestError>) -> Void) {
        self.menuService.getMenus { result in
            switch result {
            case .success(let JSON):
                guard
                    let jsonMenu = JSON["menus"],
                    let menus = try? jsonMenu.flatMap(Menu.menuList)
                else {
                    completion(Result.error(OCMRequestError(error: NSError.unexpectedError(), status: ResponseStatus.unknownError)))
                    return
                }
                self.saveMenusAndSections(from: JSON)
                completion(Result.success(menus))
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
    
    func loadElement(with identifier: String, completion: @escaping (Result<Action, NSError>) -> Void) {
        if let action = self.cachedAction(from: identifier) {
            completion(Result.success(action))
        } else {
            self.elementService.getElement(with: identifier, completion: { result in
                switch result {
                case .success(let action):
                    completion(Result.success(action))
                case .error(let error):
                    completion(Result.error(error))
                }
            })
        }
    }
    
    func loadContentList(with path: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
        self.contentListService.getContentList(with: path) { result in
            switch result {
            case .success(let json):
                guard let contentList = try? ContentList.contentList(json)
                else { return completion(.error(.unexpectedError())) }
                self.saveContentAndActions(from: json, in: path)
                completion(.success(contentList))
            case .error(let error):
                completion(.error(error as NSError))
            }
        }
    }
    
    func loadContentList(matchingString searchString: String, completion: @escaping (Result<ContentList, NSError>) -> Void) {
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
            for element in elements {
                // Save each section in menu
                self.contentPersister.save(section: element, in: menuModel.slug)
                if let elementUrl = element["elementUrl"]?.toString(),
                    let elementCache = elementsCache["\(elementUrl)"] {
                    // Save each action in section
                    self.contentPersister.save(action: elementCache, in: elementUrl)
                }
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
    
    private func cachedAction(from url: String) -> Action? {
        return self.contentPersister.loadAction(with: url)
    }

}
