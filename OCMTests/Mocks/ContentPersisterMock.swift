//
//  ContentPersisterMock.swift
//  OCM
//
//  Created by José Estela on 15/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

class ContentPersisterMock: ContentPersister {

    // MARK: - Attributes

    var spyLoadContent = (
        called: false,
        contentList: ContentList(contents: [], layout: LayoutFactory.layout(forJSON: JSON(from: [])), expiredAt: nil, contentVersion: nil)
    )

    // MARK: - ContentPersister
    
    func save(menus: [Menu]) {
        
    }
    
    func save(sections: [JSON], in menu: String) {
        
    }
    
    
    func save(action: JSON, in section: String) {
        
    }
    
    func save(action: JSON, with section: String) {
        
    }
    
    func save(content: JSON, in contentPath: String, expirationDate: Date?, contentVersion: String?) {
        
    }
    
    func loadMenus() -> [Menu] {
        return []
    }
    
    func loadAction(with identifier: String) -> Action? {
        return nil
    }
    
    func loadContentPaths() -> [String] {
        return []
    }
    
    func loadSectionForContent(with path: String) -> Section? {
        return nil
    }
    
    func loadSectionForAction(with identifier: String) -> Section? {
        return nil
    }
    
    func loadContentList(with path: String) -> ContentList? {
        self.spyLoadContent.called = true
        return self.spyLoadContent.contentList
    }
    
    func loadContentList(with path: String, validAt date: Date) -> ContentList? {
        self.spyLoadContent.called = true
        return self.spyLoadContent.contentList
    }
    
    func loadContentList(with path: String, validAt date: Date, page: Int, items: Int) -> ContentList? {
        return nil
    }
    
    func loadContentVersion(with path: String) -> String? {
        return nil
    }
    
    func cleanDataBase() {
        
    }
}
