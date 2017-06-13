//
//  ContentPersister.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData
import OCMSDK
import GIGLibrary

protocol ContentPersister {
    
    /// Method to save a menu in db (it doesnt persist the sections of the menu)
    ///
    /// - Parameter menu: The Menu model
    func save(menu: Menu)
    
    
    /// Method to save a section into a Menu
    ///
    /// - Parameters:
    ///   - section: The section json
    ///   - menu: The menu identifier
    func save(section: JSON, in menu: String)
    
    /// Method to save an action into a Section
    ///
    /// - Parameters:
    ///   - action: The action json
    ///   - section: The section identifier
    func save(action: JSON, in section: String)
    
    
    /// Method to save a content into an Action
    ///
    /// - Parameters:
    ///   - content: The content json
    ///   - contentPath: The content path
    func save(content: JSON, in contentPath: String)
    
    
    /// Method to save an action into a Content
    ///
    /// - Parameters:
    ///   - action: The action json
    ///   - identifier: The action identifier
    ///   - contentPath: The content path
    func save(action: JSON, with identifier: String, in contentPath: String)
    
    
    /// Method to load all menus
    ///
    /// - Returns: All menus object persisted
    func loadMenus() -> [Menu]
    
    
    /// Method to load an action with a identifier
    ///
    /// - Parameter identifier: The action identifier
    /// - Returns: The Action object or nil
    func loadAction(with identifier: String) -> Action?
    
    
    /// Method to load a content with the given path
    ///
    /// - Parameter path: The path of the content (usually something like: /content/XXXXXXXXX)
    /// - Returns: The ContentList object or nil
    func loadContent(with path: String) -> ContentList?
}

class ContentCoreDataPersister: ContentPersister {
    
    // MARK: - Public attributes
    
    static let shared = ContentCoreDataPersister()
    
    // MARK: - Private attributes
    
    private var notification: NSObjectProtocol?
    
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.OCMBundle().url(forResource: "ContentDB", withExtension: "momd") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    fileprivate var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - Object life cycle
    
    init() {
        self.notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillTerminate, object: nil, queue: .main) { [unowned self] _ in
            self.saveContext()
        }
        self.initDataBase()
    }
    
    deinit {
        if let notification = self.notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }
    
    // MARK: - Save methods
    
    func save(menu: Menu) {
        guard
            let menuDB = CoreDataObject<MenuDB>.create(insertingInto: self.managedObjectContext)
        else {
            return
        }
        menuDB.identifier = menu.slug
        self.saveContext()
    }
    
    func save(section: JSON, in menu: String) {
        let menuDB = CoreDataObject<MenuDB>.from(self.managedObjectContext, with: "identifier == %@", menu)
        guard
            let sections = menuDB?.mutableSetValue(forKey: "sections"),
            let sectionDB = CoreDataObject<SectionDB>.create(insertingInto: self.managedObjectContext)
        else {
            return
        }
        if let elementUrl = section["elementUrl"]?.toString() {
            sectionDB.identifier = elementUrl
            sectionDB.value = section.description.replacingOccurrences(of: "\\/", with: "/")
            sections.add(sectionDB)
            self.saveContext()
        }
    }
    
    func save(action: JSON, with identifier: String, in contentPath: String) {
        let contentDB = CoreDataObject<ContentDB>.from(self.managedObjectContext, with: "path == %@", contentPath)
        let actionDB = CoreDataObject<ActionDB>.create(insertingInto: self.managedObjectContext)
        actionDB?.identifier = identifier
        actionDB?.value = action.description.replacingOccurrences(of: "\\/", with: "/")
        if let action = actionDB {
            contentDB?.addToActions(action)
            self.saveContext()
        }
    }
    
    func save(action: JSON, in section: String) {
        guard
            let sectionDB = CoreDataObject<SectionDB>.from(self.managedObjectContext, with: "identifier == %@", section),
            let actionDB = CoreDataObject<ActionDB>.create(insertingInto: self.managedObjectContext)
        else {
            return
        }
        actionDB.identifier = section
        actionDB.value = action.description.replacingOccurrences(of: "\\/", with: "/")
        let actions = sectionDB.mutableSetValue(forKey: "actions")
        actions.add(actionDB)
        self.saveContext()
    }
    
    func save(content: JSON, in contentPath: String) {
        let actionDB = CoreDataObject<ActionDB>.from(
            self.managedObjectContext,
            with: "value CONTAINS %@", "\"contentUrl\" : \"\(contentPath)\""
        )
        let contentDB = CoreDataObject<ContentDB>.create(insertingInto: self.managedObjectContext)
        contentDB?.path = contentPath
        contentDB?.value = content.description.replacingOccurrences(of: "\\/", with: "/")
        actionDB?.content = contentDB
        self.saveContext()
    }
    
    // MARK: - Load methods
    
    func loadMenus() -> [Menu] {
        var menus: [Menu] = []
        for menuDB in self.loadAllMenusFromDB() {
            if let menuDB = menuDB, let menu = self.mapToMenu(menuDB) {
                menus.append(menu)
            }
        }
        return menus
    }
    
    func loadAction(with identifier: String) -> Action? {
        guard
            let action = CoreDataObject<ActionDB>.from(self.managedObjectContext, with: "identifier == %@", identifier),
            let json = JSON.fromString(action.value ?? "")
        else {
            return nil
        }
        return ActionFactory.action(from: json)
    }
    
    func loadContent(with path: String) -> ContentList? {
        guard
            let content = CoreDataObject<ContentDB>.from(self.managedObjectContext, with: "path == %@", path),
            let json = JSON.fromString(content.value ?? "")
        else {
            return nil
        }
        return try? ContentList.contentList(json)
    }
    
    // MARK: - Core Data Saving support
    
    fileprivate func saveContext() {
        guard let managedObjectContext = self.managedObjectContext else { return }
        if managedObjectContext.hasChanges {
            managedObjectContext.save()
        }
    }
    
    fileprivate func initDataBase() {
        guard let managedObjectModel = self.managedObjectModel else { return }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ContentDB.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch let error {
            print(error)
        }
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = coordinator
        self.managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

private extension ContentCoreDataPersister {
    
    func loadAllMenusFromDB() -> [MenuDB?] {
        return CoreDataArray<MenuDB>.from(self.managedObjectContext) ?? []
    }
    
    // MARK: - Helpers
    
    func mapToMenu(_ menuDB: MenuDB) -> Menu? {
        guard let identifier = menuDB.identifier, let sectionsDB = menuDB.sections else { return nil }
        var sections: [Section] = []
        for sectionDB in sectionsDB {
            if let sectionDB = sectionDB as? SectionDB, let section = self.mapToSection(sectionDB) {
                sections.append(section)
            }
        }
        return Menu(slug: identifier, sections: sections)
    }
    
    func mapToSection(_ sectionDB: SectionDB) -> Section? {
        guard let value = sectionDB.value, let json = JSON.fromString(value) else { return nil }
        return Section.parseSection(json: json)
    }
}
