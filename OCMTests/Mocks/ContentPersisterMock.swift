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
    
    func save(menu: Menu) {
        
    }
    
    func save(section: JSON, in menu: String) {
        
    }
    
    
    func save(action: JSON, in section: String) {
        
    }
    
    func save(content: JSON, in contentPath: String) {
        
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
}
