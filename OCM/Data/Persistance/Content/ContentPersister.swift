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
    func loadContent(with path: String) -> ContentList?
    
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

//swiftlint:disable file_length

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
        self.managedObjectContext?.perform({
            // First, check if the already saved menus have any menu that was deleted
            let menusDB = self.loadAllMenus().flatMap({ $0 })
            let sectionsNotContaining = self.itemsNotContaining(menusDB, in: menus, where: { fetchedMenu, menu in
                menu.slug == fetchedMenu.identifier
            })
            // Remove from db
            _ = sectionsNotContaining.map {
                print("Deleting menu \($0)")
                self.managedObjectContext?.delete($0)
            }
            self.saveContext()
            // Now add the menus that dont exist yet in db
            for menu in menus {
                if self.fetchMenu(with: menu.slug) == nil {
                    if let menuDB = self.createMenu() {
                        menuDB.identifier = menu.slug
                    }
                }
            }
            self.saveContext()
        })
    }
    
    func save(sections: [JSON], in menu: String) {
        self.managedObjectContext?.perform({ 
            // First, check if the already saved sections have any section that was deleted
            let menus = self.loadMenus().flatMap({ $0.slug == menu ? $0 : nil })
            if menus.count > 0 {
                // Sections that are not in the new json
                let sectionsNotContaining = self.itemsNotContaining(menus[0].sections, in: sections, where: { section, json in
                    section.elementUrl == json["elementUrl"]?.toString()
                })
                // Remove from db
                _ = sectionsNotContaining.map({
                    if let sectionDB = self.fetchSection(with: $0.elementUrl) {
                        print("Deleting section \(sectionDB) from \($0)")
                        self.fetchMenu(with: menu)?.removeFromSections(sectionDB)
                        self.managedObjectContext?.delete(sectionDB)
                    }
                })
                self.saveContext()
            }
            // Now, add or update the sections
            for (index, section) in sections.enumerated() {
                guard let elementUrl = section["elementUrl"]?.toString() else { logWarn("elementUrl is nil"); return }
                let fetchedSection = self.fetchSection(with: elementUrl)
                let sectionDB = fetchedSection ?? self.createSection()
                sectionDB?.orderIndex = Int64(index)
                sectionDB?.identifier = elementUrl
                sectionDB?.value = section.description.replacingOccurrences(of: "\\/", with: "/")
                if let sectionDB = sectionDB, fetchedSection == nil {
                    self.fetchMenu(with: menu)?.addToSections(sectionDB)
                } else if let fetchedSection = fetchedSection {
                    fetchedSection.menu = self.fetchMenu(with: menu)
                }
            }
            self.saveContext()
        })
    }
    
    func save(action: JSON, in section: String) {
        self.managedObjectContext?.perform({
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
        })
    }
    
    func save(content: JSON, in contentPath: String, expirationDate: Date?) {
        self.managedObjectContext?.perform({
            let actionDB = CoreDataObject<ActionDB>.from(
                self.managedObjectContext,
                with: "value CONTAINS %@", "\"contentUrl\" : \"\(contentPath)\""
            )
            if actionDB != nil {
                if let contentDB = self.fetchContent(with: contentPath) {
                    contentDB.value = content.description.replacingOccurrences(of: "\\/", with: "/")
                } else {
                    let contentDB = self.createContent()
                    contentDB?.path = contentPath
                    contentDB?.value = content.description.replacingOccurrences(of: "\\/", with: "/")
                    contentDB?.expirationDate = expirationDate
                    actionDB?.content = contentDB
                }
                self.saveContext()
            }
        })
    }
    
    func save(action: JSON, with identifier: String, in contentPath: String) {
        self.managedObjectContext?.perform({
            if let actionDB = self.fetchAction(with: identifier), let contentDB = self.fetchContent(with: contentPath) {
                actionDB.value = action.description.replacingOccurrences(of: "\\/", with: "/")
                guard let contains = actionDB.contentOwners?.contains(where: { content in
                    if let content = content as? ContentDB {
                        return content.path == contentPath
                    }
                    return false
                }) else { return }
                if !contains {
                    actionDB.addToContentOwners(contentDB)
                }
                self.saveContext()
            } else {
                let contentDB = self.fetchContent(with: contentPath)
                let actionDB = self.createAction()
                actionDB?.identifier = identifier
                actionDB?.value = action.description.replacingOccurrences(of: "\\/", with: "/")
                if let action = actionDB {
                    contentDB?.addToActions(action)
                    self.saveContext()
                }
            }
        })
    }
    
    // MARK: - Load methods
    
    func loadMenus() -> [Menu] {
        var menus: [Menu] = []
        for menuDB in self.loadAllMenus() {
            self.managedObjectContext?.performAndWait({
                if let menuDB = menuDB, let menu = self.mapToMenu(menuDB) {
                    menus.append(menu)
                }
            })
        }
        return menus
    }
    
    func loadAction(with identifier: String) -> Action? {
        guard let action = self.fetchAction(with: identifier) else { return nil }
        var actionValue: String?
        self.managedObjectContext?.performAndWait({
            actionValue = action.value
        })
        guard let json = JSON.fromString(actionValue ?? "") else { return nil }
        return ActionFactory.action(from: json, identifier: identifier)
    }
    
    func loadContent(with path: String) -> ContentList? {
        
        guard let content = self.fetchContent(with: path) else { return nil }
        var contentValue: String?
        self.managedObjectContext?.performAndWait({
            contentValue = content.value
        })
        guard let json = JSON.fromString(contentValue ?? "") else { return nil }
        return try? ContentList.contentList(json)
    }
    
    func loadContentPaths() -> [String] {
        let paths = self.fetchContent().flatMap { (content) -> String? in
            var contentPath: String?
            self.managedObjectContext?.performAndWait({
                contentPath = content?.path
            })
            return contentPath
        }
        return paths
    }
    
    func loadSectionForContent(with path: String) -> Section? {
        guard let content = self.fetchContent(with: path) else { logWarn("fechtContent with path: \(path) is nil"); return nil }
        var sectionValue: String?
        self.managedObjectContext?.performAndWait({
            sectionValue = content.actionOwner?.section?.value
        })
        guard let json = JSON.fromString(sectionValue ?? "") else { logWarn("SectionValue is nil"); return nil }
        return Section.parseSection(json: json)
    }
    
    func loadSectionForAction(with identifier: String) -> Section? {
        guard let action = self.fetchAction(with: identifier) else { return nil }
        var sectionValue: String?
        self.managedObjectContext?.performAndWait({
            sectionValue = action.section?.value
        })
        guard let json = JSON.fromString(sectionValue ?? "") else { logWarn("SectionValue is nil"); return nil }
        return Section.parseSection(json: json)
    }
    
    // MARK: - Delete methods
    
    func cleanDataBase() {
        // Delete all menus in db (it deletes in cascade all data)
        self.managedObjectContext?.perform({
            _ = self.loadAllMenus().flatMap { $0 }.map {
                self.managedObjectContext?.delete($0)
            }
            _ = self.loadAllActions().flatMap { $0 }.map {
                self.managedObjectContext?.delete($0)
            }
            _ = self.loadAllContents().flatMap { $0 }.map {
                self.managedObjectContext?.delete($0)
            }
            self.saveContext()
        })
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
    
    func loadAllActions() -> [ActionDB?] {
        return CoreDataArray<ActionDB>.from(self.managedObjectContext) ?? []
    }
    
    func loadAllContents() -> [ContentDB?] {
        return CoreDataArray<ContentDB>.from(self.managedObjectContext) ?? []
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
    
    func fetchContent() -> [ContentDB?] {
        return CoreDataArray<ContentDB>.from(self.managedObjectContext) ?? []
    }
    
    func itemsNotContaining<T, S>(_ firstArray: [T], in secondArray: [S], where contain: (T, S) -> Bool) -> [T] {
        return firstArray.flatMap({ item in
            secondArray.contains(where: { contain(item, $0) }) ? nil : item
        })
    }
    
    // MARK: - Map model helpers
    
    func mapToMenu(_ menuDB: MenuDB) -> Menu? {
        guard let identifier = menuDB.identifier, let sectionsDB = menuDB.sections?.allObjects as? [SectionDB] else { return nil }
        var sections: [Section] = []
        let sortedSections = sectionsDB.sorted(by: {
            $0.orderIndex < $1.orderIndex
        })
        for sectionDB in sortedSections {
            if let section = self.mapToSection(sectionDB) {
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

//swiftlint:enable file_length
