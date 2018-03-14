//
//  ContentPersister.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ContentPersister {
    
    /// Method to save an array of menus in db (it doesnt persist the sections of the menu)
    ///
    /// - Parameter menus: The Menu model array
    func save(menus: [Menu])
    
    
    /// Method to save an array of sections into a Menu
    ///
    /// - Parameters:
    ///   - section: The sections json array
    ///   - menu: The menu identifier
    func save(sections: [JSON], in menu: String)
    
    /// Method to save an action into a Section
    ///
    /// - Parameters:
    ///   - action: The action json
    ///   - section: The section identifier
    func save(action: JSON, in section: String)
    
    /// Method to save a `ContentList` into an `Action`
    ///
    /// - Parameters:
    ///   - content: The content json
    ///   - contentPath: The content path
    ///   - expirationDate: Date of expiration (if defined)
    ///   - contentVersion: The content version
    func save(content: JSON, in contentPath: String, expirationDate: Date?, contentVersion: String?)
    
    /// Method to append contents of a `ContentList`
    ///
    /// - Parameters:
    ///   - content: The JSON with contents to append
    ///   - contentPath: The content path
    ///   - expirationDate: Date of expiration (if defined)
    func append(content: JSON, in contentPath: String, expirationDate: Date?)

    /// Method to save an action into an element given the element url of the element
    ///
    /// - Parameters:
    ///   - action: The action json
    ///   - identifier: The action identifier
    func save(action: JSON, with identifier: String)
    
    /// Method to load all menus
    ///
    /// - Returns: All menus object persisted
    func loadMenus() -> [Menu]
    
    /// Method to load an action with a identifier
    ///
    /// - Parameter identifier: The action identifier
    /// - Returns: The `Action` object or nil
    func loadAction(with identifier: String) -> Action?
    
    /// Method to load a content with the given path
    ///
    /// - Parameter path: The path of the content (usually something like: /content/XXXXXXXXX)
    /// - Returns: The `ContentList` object or nil
    func loadContentList(with path: String) -> ContentList?
    
    /// Method to load a content with the given path with it's contents filtered by page and number of items
    ///
    /// - Parameters:
    ///   - path: The path of the content (usually something like: /content/XXXXXXXXX)
    ///   - validAt: The date to evaluate if the content is valid or expired
    ///   - page: The index for the page to load
    ///   - items: The number of items
    /// - Returns: The filterted `ContentList` object or nil
    func loadContentList(with path: String, validAt date: Date, page: Int, items: Int) -> ContentList?
    
    /// Method to load stored paths for contents
    ///
    /// - Returns: An array with the stored paths
    func loadContentPaths() -> [String]
    
    /// Method to load section related to a content (if any) with the given path
    ///
    /// - Parameter path: The path of the content (usually something like: /content/XXXXXXXXX)
    /// - Returns: The Section object or nil
    func loadSectionForContent(with path: String) -> Section?
    
    /// Method to load section related to an action (if any) with the given identifier
    ///
    /// - Parameter identifier: The action identifier
    /// - Returns: The Section object or nil
    func loadSectionForAction(with identifier: String) -> Section?
        
    /// Method to load the content version for the content with the given path
    ///
    /// - Parameter path: The path of the content (usually something like: /content/XXXXXXXXX)
    /// - Returns: The stored version for the content
    func loadContentVersion(with path: String) -> String?
    
    /// Method to clean all database
    func cleanDataBase()
}
