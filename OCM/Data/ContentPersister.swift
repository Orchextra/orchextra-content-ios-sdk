//
//  ContentPersister.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData
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
    
    fileprivate var notification: NSObjectProtocol?
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
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
        if self.fetchMenu(with: menu.slug) == nil {
            if let menuDB = createMenu() {
                menuDB.identifier = menu.slug
            }
            self.saveContext()
        }
    }
    
    func save(section: JSON, in menu: String) {
        guard let elementUrl = section["elementUrl"]?.toString() else { return }
        if let sectionDB = self.fetchSection(with: elementUrl) {
            // Remove section with all relationships
            self.managedObjectContext?.delete(sectionDB)
            self.saveContext()
        }
        let sectionDB = self.createSection()
        sectionDB?.identifier = elementUrl
        sectionDB?.value = section.description.replacingOccurrences(of: "\\/", with: "/")
        if let sectionDB = sectionDB {
            self.fetchMenu(with: menu)?.addToSections(sectionDB)
            self.saveContext()
        }
    }
    
    func save(action: JSON, with identifier: String, in contentPath: String) {
        let contentDB = self.fetchContent(with: contentPath)
        let actionDB = self.createAction()
        actionDB?.identifier = identifier
        actionDB?.value = action.description.replacingOccurrences(of: "\\/", with: "/")
        if let action = actionDB {
            contentDB?.addToActions(action)
            self.saveContext()
        }
    }
    
    func save(action: JSON, in section: String) {
        guard
            let sectionDB = self.fetchSection(with: section),
            let actionDB = self.createAction()
        else {
            return
        }
        actionDB.identifier = section
        actionDB.value = action.description.replacingOccurrences(of: "\\/", with: "/")
        sectionDB.addToActions(actionDB)
        self.saveContext()
    }
    
    func save(content: JSON, in contentPath: String) {
        let actionDB = CoreDataObject<ActionDB>.from(
            self.managedObjectContext,
            with: "value CONTAINS %@", "\"contentUrl\" : \"\(contentPath)\""
        )
        let contentDB = self.createContent()
        contentDB?.path = contentPath
        contentDB?.value = content.description.replacingOccurrences(of: "\\/", with: "/")
        actionDB?.content = contentDB
        self.saveContext()
    }
    
    // MARK: - Load methods
    
    func loadMenus() -> [Menu] {
        var menus: [Menu] = []
        for menuDB in self.loadAllMenus() {
            if let menuDB = menuDB, let menu = self.mapToMenu(menuDB) {
                menus.append(menu)
            }
        }
        return menus
    }
    
    func loadAction(with identifier: String) -> Action? {
        guard
            let action = self.fetchAction(with: identifier),
            let json = JSON.fromString(action.value ?? "")
        else {
            return nil
        }
        return ActionFactory.action(from: json)
    }
    
    func loadContent(with path: String) -> ContentList? {
        guard
            let content = self.fetchContent(with: path),
            let json = JSON.fromString(content.value ?? "")
        else {
            return nil
        }
        return try? ContentList.contentList(json)
    }
}

private extension ContentCoreDataPersister {
    
    // MARK: - DataBase helpers
    
    func createMenu() -> MenuDB? {
        return CoreDataObject<MenuDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchMenu(with slug: String) -> MenuDB? {
        return CoreDataObject<MenuDB>.from(self.managedObjectContext, with: "identifier == %@", slug)
    }
    
    func loadAllMenus() -> [MenuDB?] {
        return CoreDataArray<MenuDB>.from(self.managedObjectContext) ?? []
    }
    
    func createSection() -> SectionDB? {
        return CoreDataObject<SectionDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchSection(with elementUrl: String) -> SectionDB? {
        return CoreDataObject<SectionDB>.from(self.managedObjectContext, with: "identifier == %@", elementUrl)
    }
    
    func createAction() -> ActionDB? {
        return CoreDataObject<ActionDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchAction(with identifier: String) -> ActionDB? {
        return CoreDataObject<ActionDB>.from(self.managedObjectContext, with: "identifier == %@", identifier)
    }
    
    func createContent() -> ContentDB? {
        return CoreDataObject<ContentDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchContent(with path: String) -> ContentDB? {
        return CoreDataObject<ContentDB>.from(self.managedObjectContext, with: "path == %@", path)
    }
    
    // MARK: - Map model helpers
    
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
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        guard let managedObjectContext = self.managedObjectContext else { return }
        if managedObjectContext.hasChanges {
            managedObjectContext.save()
        }
    }
    
    func initDataBase() {
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
