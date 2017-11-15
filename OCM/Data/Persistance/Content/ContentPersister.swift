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

//swiftlint:disable file_length
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
    
    
    /// Method to save a content into an Action
    ///
    /// - Parameters:
    ///   - content: The content json
    ///   - contentPath: The content path
    ///   - expirationDate: Date of expiration (if defined)
    func save(content: JSON, in contentPath: String, expirationDate: Date?)
    
    
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
    func loadContentList(with path: String) -> ContentList?
    
    /// Method to load a content with the given path and the date to filter the content
    ///
    /// - Parameter path: The path of the content (usually something like: /content/XXXXXXXXX)
    /// - Parameter validAt: !!!
    /// - Returns: The ContentList object or nil
    func loadContentList(with path: String, validAt date: Date) -> ContentList?
    
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
    
    /// Method to clean all database
    func cleanDataBase()
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
    
    func save(menus: [Menu]) {
        // First, we need to check if any of the already saved menus has been deleted
        self.managedObjectContext?.saveAfter {
            let setOfMenus = Set(menus.map({ $0.slug }))
            let setOfDBMenus = Set(self.loadAllMenus().flatMap({ $0?.identifier }))
            setOfDBMenus
                .subtracting(setOfMenus)
                .flatMap({ self.fetchMenuFromDB(with: $0) })
                .forEach({ self.managedObjectContext?.delete($0) })
        }
        // Now we add new menus
        self.managedObjectContext?.saveAfter {
            for menu in menus where self.fetchMenuFromDB(with: menu.slug) == nil {
                if let menuDB = self.createMenu() {
                    menuDB.identifier = menu.slug
                }
            }
        }
    }
    
    func save(sections: [JSON], in menu: String) {
        // First, we need to check if any of the already saved sections has been deleted
        self.managedObjectContext?.saveAfter {
            let menus = self.loadMenus().flatMap({ $0.slug == menu ? $0 : nil })
            if menus.count > 0 {
                // Sections that are not in the new json
                let setOfSections = Set(menus[0].sections.map({ $0.elementUrl }))
                let setOfDBSections = Set(sections.flatMap({ $0["elementUrl"]?.toString() }))
                // Remove from db
                setOfDBSections
                    .subtracting(setOfSections)
                    .flatMap({ self.fetchSectionFromDB(with: $0) })
                    .forEach({ self.fetchMenuFromDB(with: menu)?.removeFromSections($0) })
            }
        }
        self.managedObjectContext?.saveAfter {
            // Now, add or update the sections
            for (index, section) in sections.enumerated() {
                guard let elementUrl = section["elementUrl"]?.toString() else { logWarn("elementUrl is nil"); return }
                let fetchedSection = self.fetchSectionFromDB(with: elementUrl)
                let sectionDB = fetchedSection ?? self.createSection()
                sectionDB?.orderIndex = Int64(index)
                sectionDB?.identifier = elementUrl
                sectionDB?.value = section.stringRepresentation()
                if let sectionDB = sectionDB, fetchedSection == nil {
                    self.fetchMenuFromDB(with: menu)?.addToSections(sectionDB)
                } else if let fetchedSection = fetchedSection {
                    fetchedSection.menu = self.fetchMenuFromDB(with: menu)
                }
            }
        }
    }
    
    func save(action: JSON, in section: String) {
        self.managedObjectContext?.saveAfter {
            guard let sectionDB = self.fetchSectionFromDB(with: section), let actionDB = self.createAction() else {
                logWarn("There is an error getting section \(section) from db")
                return
            }
            actionDB.identifier = section
            actionDB.value = action.stringRepresentation()
            sectionDB.addToActions(actionDB)
        }
    }
    
    
    func save(content: JSON, in contentPath: String, expirationDate: Date?) {
        self.managedObjectContext?.saveAfter {
            let actionDB = CoreDataObject<ActionDB>.from(self.managedObjectContext, with: "value CONTAINS %@", "\"contentUrl\" : \"\(contentPath)\"")
            if actionDB != nil {
                if let contentDB = self.fetchContentListFromDB(with: contentPath) {
                    contentDB.elements?.flatMap({ $0 as? ElementDB }).forEach({ self.managedObjectContext?.delete($0) }) // Delete from db each element in Content list
                    self.saveContentList(contentDB, with: content, in: contentPath, expirationDate: expirationDate)
                } else {
                    let contentDB = self.createContentList()
                    self.saveContentList(contentDB, with: content, in: contentPath, expirationDate: expirationDate)
                }
            }
        }
    }
    
    func save(action: JSON, with identifier: String, in contentPath: String) {
        self.managedObjectContext?.saveAfter {
            if let actionDB = self.fetchActionFromDB(with: identifier), let contentDB = self.fetchContentListFromDB(with: contentPath) {
                actionDB.value = action.stringRepresentation()
                guard let contains = actionDB.contentOwners?.contains(where: { content in
                    if let content = content as? ContentListDB {
                        return content.path == contentPath
                    }
                    return false
                }) else { return }
                if !contains {
                    actionDB.addToContentOwners(contentDB)
                }
            } else {
                let contentDB = self.fetchContentListFromDB(with: contentPath)
                let actionDB = self.createAction()
                actionDB?.identifier = identifier
                actionDB?.value = action.stringRepresentation()
                if let action = actionDB {
                    contentDB?.addToActions(action)
                }
            }
        }
    }
    
    // MARK: - Load methods
    
    func loadMenus() -> [Menu] {
        var menus: [Menu] = []
        self.managedObjectContext?.performAndWait {
            menus = self.loadAllMenus()
                .flatMap({ $0 })
                .flatMap({ $0.toMenu() })
        }
        return menus
    }
    
    func loadAction(with identifier: String) -> Action? {
        guard let action = self.fetchActionFromDB(with: identifier) else { return nil }
        var actionValue: String?
        self.managedObjectContext?.performAndWait {
            actionValue = action.value
        }
        guard let json = JSON.fromString(actionValue ?? "") else { return nil }
        return ActionFactory.action(from: json, identifier: identifier)
    }
    
    func loadContentList(with path: String) -> ContentList? {
        guard let contentListDB = self.fetchContentListFromDB(with: path) else { return nil }
        var contentList: ContentList?
        self.managedObjectContext?.performAndWait {
            contentList = contentListDB.toContentList()
        }
        return contentList
    }
    
    func loadContentList(with path: String, validAt date: Date) -> ContentList? {
        guard let contentListDB = self.fetchContentListFromDB(with: path) else { return nil }
        var contentList: ContentList?
        self.managedObjectContext?.performAndWait {
            // TODO: Check date
            contentList = contentListDB.toContentList()
        }
        return contentList
    }
    
    func loadContentPaths() -> [String] {
        let paths = self.fetchContentListFromDB().flatMap { (content) -> String? in
            var contentPath: String?
            self.managedObjectContext?.performAndWait {
                contentPath = content?.path
            }
            return contentPath
        }
        return paths
    }
    
    func loadSectionForContent(with path: String) -> Section? {
        guard let content = self.fetchContentListFromDB(with: path) else { logWarn("fechtContent with path: \(path) is nil"); return nil }
        var sectionValue: String?
        self.managedObjectContext?.performAndWait {
            sectionValue = content.actionOwner?.section?.value
        }
        guard let json = JSON.fromString(sectionValue ?? "") else { logWarn("SectionValue is nil"); return nil }
        return Section.parseSection(json: json)
    }
    
    func loadSectionForAction(with identifier: String) -> Section? {
        guard let action = self.fetchActionFromDB(with: identifier) else { return nil }
        var sectionValue: String?
        self.managedObjectContext?.performAndWait {
            sectionValue = action.section?.value
        }
        guard let json = JSON.fromString(sectionValue ?? "") else { logWarn("SectionValue is nil"); return nil }
        return Section.parseSection(json: json)
    }
    
    // MARK: - Delete methods
    
    func cleanDataBase() {
        // Delete all data in data base
        self.managedObjectContext?.saveAfter {
            self.loadAllMenus().flatMap { $0 }.forEach { self.managedObjectContext?.delete($0) }
            self.loadAllSections().flatMap { $0 }.forEach { self.managedObjectContext?.delete($0) }
            self.loadAllElements().flatMap { $0 }.forEach { self.managedObjectContext?.delete($0) }
            self.loadAllActions().flatMap { $0 }.forEach { self.managedObjectContext?.delete($0) }
            self.loadAllContentLists().flatMap { $0 }.forEach { self.managedObjectContext?.delete($0) }
        }
    }
}

private extension ContentCoreDataPersister {
    
    // MARK: - DataBase helpers
    
    func createMenu() -> MenuDB? {
        return CoreDataObject<MenuDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchMenuFromDB(with slug: String) -> MenuDB? {
        return CoreDataObject<MenuDB>.from(self.managedObjectContext, with: "identifier == %@", slug)
    }
    
    func loadAllMenus() -> [MenuDB?] {
        return CoreDataArray<MenuDB>.from(self.managedObjectContext) ?? []
    }
    
    func loadAllActions() -> [ActionDB?] {
        return CoreDataArray<ActionDB>.from(self.managedObjectContext) ?? []
    }
    
    func loadAllContentLists() -> [ContentListDB?] {
        return CoreDataArray<ContentListDB>.from(self.managedObjectContext) ?? []
    }
    
    func loadAllSections() -> [SectionDB?] {
        return CoreDataArray<SectionDB>.from(self.managedObjectContext) ?? []
    }
    
    func loadAllElements() -> [ElementDB?] {
        return CoreDataArray<ElementDB>.from(self.managedObjectContext) ?? []
    }
    
    func createSection() -> SectionDB? {
        return CoreDataObject<SectionDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchSectionFromDB(with elementUrl: String) -> SectionDB? {
        return CoreDataObject<SectionDB>.from(self.managedObjectContext, with: "identifier == %@", elementUrl)
    }
    
    func createAction() -> ActionDB? {
        return CoreDataObject<ActionDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchActionFromDB(with identifier: String) -> ActionDB? {
        return CoreDataObject<ActionDB>.from(self.managedObjectContext, with: "identifier == %@", identifier)
    }
    
    func createContentList() -> ContentListDB? {
        return CoreDataObject<ContentListDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchContentListFromDB(with path: String) -> ContentListDB? {
        return CoreDataObject<ContentListDB>.from(self.managedObjectContext, with: "path == %@", path)
    }
    
    func fetchContentListFromDB() -> [ContentListDB?] {
        return CoreDataArray<ContentListDB>.from(self.managedObjectContext) ?? []
    }
    
    func createElement() -> ElementDB? {
        return CoreDataObject<ElementDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func fetchElementFromDB(with contentList: ContentListDB, validAt date: Date) -> ElementDB? {
        // TODO: Add validation of date
        return CoreDataObject<ElementDB>.from(self.managedObjectContext, with: "contentList == %@", contentList)
    }
    
    func createContentDates() -> ScheduleDateDB? {
        return CoreDataObject<ScheduleDateDB>.create(insertingInto: self.managedObjectContext)
    }
    
    func saveContentList(_ contentListDB: ContentListDB?, with content: JSON, in contentPath: String, expirationDate: Date?) {
        guard let contentListDB = contentListDB else { return }
        let contentList = try? ContentList.contentList(content)
        contentListDB.path = contentPath
        contentListDB.expirationDate = expirationDate as NSDate?
        contentListDB.elementsCache = content["elementsCache"]?.toString()
        contentListDB.slug = content["content.slug"]?.toString()
        contentListDB.type = content["content.type"]?.toString()
        contentListDB.tags = content["content.tags"]?.toString()?.data(using: .utf8) as? NSData
        contentListDB.layout = content["content.layout"]?.stringRepresentation()
        guard let contents = contentList?.contents else { return }
        for (index, content) in contents.enumerated() {
            guard let element = self.createElement() else { return }
            element.orderIndex = Int64(index)
            element.value = content.toJSON()?.stringRepresentation()
            contentListDB.addToElements(element)
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        guard let managedObjectContext = self.managedObjectContext else { logWarn("managedObjectContext is nil"); return }
        managedObjectContext.perform { 
            if managedObjectContext.hasChanges {
                managedObjectContext.save()
            }
        }
    }
    
    func initDataBase() {
        guard let managedObjectModel = self.managedObjectModel else { logWarn("managedObjectModel is nil"); return }
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ContentDB.sqlite")
        let options = [ NSInferMappingModelAutomaticallyOption: true,
                        NSMigratePersistentStoresAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let error {
            print(error)
        }
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = coordinator
        self.managedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

private extension NSManagedObjectContext {
    
    func saveAfter(_ completion: @escaping () -> Void) {
        self.perform {
            completion()
            if self.hasChanges {
                self.save()
            }
        }
    }
    
}
//swiftlint:enable file_length
