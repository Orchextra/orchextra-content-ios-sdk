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

struct ContentPersisterMock: ContentPersister {

    func save(menus: [Menu]) {
        
    }
    
    func save(sections: [JSON], in menu: String) {
        
    }
    
    
    func save(action: JSON, in section: String) {
        
    }
    
    func save(content: JSON, in contentPath: String, expirationDate: Date?) {
        
    }
    
    
    func save(action: JSON, with identifier: String, in contentPath: String) {
        
    }
    
    func loadMenus() -> [Menu] {
        return []
    }
    
    func loadAction(with identifier: String) -> Action? {
        return nil
    }
    
    func loadContent(with path: String) -> ContentList? {
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
    
    func cleanDataBase() {
        
    }
}
