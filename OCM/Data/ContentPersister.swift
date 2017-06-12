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
    func save(menu: Menu)
    func save(section: JSON, in menu: String)
    func save(action: JSON, inContent contentPath: String)
    func save(action: JSON, in section: String)
    func save(content: JSON, in actionPath: String)
    func loadMenus() -> [Menu]
    func loadAction(with identifier: String) -> Action?
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
            let managedObjectContext = self.managedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Menu", in: managedObjectContext)
        else {
            return
        }
        let menuDB = MenuDB(entity: entity, insertInto: managedObjectContext)
        menuDB.identifier = menu.slug
        self.saveContext()
    }
    
    func save(section: JSON, in menu: String) {
        let menuDB = self.loadMenuFromDB(with: menu)
        guard
            let sections = menuDB?.mutableSetValue(forKey: "sections"),
            let managedObjectContext = self.managedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Section", in: managedObjectContext)
        else {
            return
        }
        let sectionDB = SectionDB(entity: entity, insertInto: self.managedObjectContext)
        if let elementUrl = section["elementUrl"]?.toString() {
            sectionDB.identifier = elementUrl
            sectionDB.value = section.description.replacingOccurrences(of: "\\/", with: "/")
            sections.add(sectionDB)
            self.saveContext()
        }
    }
    
    func save(action: JSON, inContent contentPath: String) {
        // TODO: Implement the option to save an action knowing the content path (and no the section identifier)
    }
    
    func save(action: JSON, in section: String) {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Section")
        fetch.predicate = NSPredicate(format: "identifier == %@", section)
        guard let results = try? self.managedObjectContext?.fetch(fetch), let sections = results as? [SectionDB] else { return }
        if sections.indices.contains(0) {
            guard let managedObjectContext = self.managedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "Action", in: managedObjectContext) else { return }
            let actionDB = ActionDB(entity: entity, insertInto: managedObjectContext)
            actionDB.identifier = section
            actionDB.value = action.description.replacingOccurrences(of: "\\/", with: "/")
            let actions = sections[0].mutableSetValue(forKey: "actions")
            actions.add(actionDB)
            self.saveContext()
        }
    }
    
    func save(content: JSON, in actionPath: String) {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Action")
        fetch.predicate = NSPredicate(format: "value CONTAINS %@", "\"contentUrl\" : \"\(actionPath)\"")
        guard let results = try? self.managedObjectContext?.fetch(fetch), let contents = results as? [ActionDB] else { return }
        if contents.indices.contains(0) {
            guard let managedObjectContext = self.managedObjectContext, let entity = NSEntityDescription.entity(forEntityName: "Content", in: managedObjectContext) else { return }
            let contentDB = ContentDB(entity: entity, insertInto: managedObjectContext)
            contentDB.path = actionPath
            contentDB.value = content.description.replacingOccurrences(of: "\\/", with: "/")
            contents[0].content = contentDB
            self.saveContext()
        }
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
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Action")
        fetch.predicate = NSPredicate(format: "identifier == %@", identifier)
        guard let results = try? self.managedObjectContext?.fetch(fetch), let actions = results as? [ActionDB] else { return nil }
        if actions.indices.contains(0) {
            if let json = JSON.fromString(actions[0].value ?? "") {
                return ActionFactory.action(from: json)
            }
        }
        return nil
    }
    
    func loadContent(with path: String) -> ContentList? {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Content")
        fetch.predicate = NSPredicate(format: "path == %@", path)
        guard let results = try? self.managedObjectContext?.fetch(fetch), let contents = results as? [ContentDB] else { return nil }
        if contents.indices.contains(0) {
            if let json = JSON.fromString(contents[0].value ?? "") {
                return try? ContentList.contentList(json)
            }
        }
        return nil
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
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Menu")
        guard let results = try? self.managedObjectContext?.fetch(fetch), let menus = results as? [MenuDB] else { return [] }
        if menus.indices.contains(0) {
            return menus
        }
        return []
    }
    
    func loadMenuFromDB(with identifier: String) -> MenuDB? {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Menu")
        fetch.predicate = NSPredicate(format: "identifier == %@", identifier)
        guard let results = try? self.managedObjectContext?.fetch(fetch), let menus = results as? [MenuDB] else { return nil }
        if menus.indices.contains(0) {
            return menus[0]
        }
        return nil
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
