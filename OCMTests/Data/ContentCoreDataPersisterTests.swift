//
//  ContentCoreDataPersisterTests.swift
//  OCMTests
//
//  Created by José Estela on 7/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import XCTest
import GIGLibrary
import Nimble
import CoreData
@testable import OCMSDK

class ContentCoreDataPersisterTests: XCTestCase {
    
    // MARK: - Attributes
    
    var persister: ContentCoreDataPersister!
    var managedObjectContext: NSManagedObjectContext!
    
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel! = {
        guard let modelURL = Bundle.OCMBundle().url(forResource: "ContentDB", withExtension: "momd") else { return nil }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    override func setUp() {
        super.setUp()
        self.managedObjectContext = setUpInMemoryManagedObjectContext()
        self.persister = ContentCoreDataPersister(managedObjectContext: self.managedObjectContext)
    }
    
    override func tearDown() {
        self.managedObjectContext = nil
        self.persister = nil
        super.tearDown()
    }
    
    func test_persister_saveMenusCorrectly() {
        // Arrange
        let json = JSON.from(file: "menus_ok")
        let menus = json["data.menus"]!.flatMap({ try? Menu.menuList($0) })
        // Act
        self.saveMenusAndSections(from: json)
        // Assert
        expect(self.persister.loadMenus().map({ $0.slug })).toEventually(equal(menus.map({ $0.slug })))
    }
    
    func test_persister_shouldSaveMenusAndSectionsCorrectly() {
        // Arrange
        let json = JSON.from(file: "menus_ok")
        let menus = json["data.menus"]!.flatMap({ try? Menu.menuList($0) })
        // Act
        self.saveMenusAndSections(from: json)
        // Assert
        expect(self.persister.loadMenus()).toEventually(equal(menus))
    }
    
    func test_persister_shouldSaveContentListCorrectly() {
        // Arrange
        let menusJson = JSON.from(file: "menus_ok")
        let contentListJson = JSON.from(file: "contentlist_ok")
        let contentList = try! ContentList.contentList(contentListJson)
        // Act
        self.saveMenusAndSections(from: menusJson)
        self.saveContentAndActions(from: contentListJson, in: "/content/5853e73f71905538c7a36049")
        // Assert
        let contentListInDB = self.persister.loadContentList(with: "/content/5853e73f71905538c7a36049")!
        expect(contentList.contents).toEventually(equal(contentListInDB.contents))
    }
    
    func test_persister_whenThereAreSectionsAlreadySaved_andNewSectionsWantToBeSaved_shouldRemoveNonexistentDBSectionsInNewSections() {
        // Arrange
        let json = JSON.from(file: "menus_ok")
        let jsonWithOneSection = JSON.from(file: "menus_ok_with_one_section")
        let menusWithOneSection = jsonWithOneSection["data.menus"]!.flatMap({ try? Menu.menuList($0) })
        // Act
        self.saveMenusAndSections(from: json)
        self.saveMenusAndSections(from: jsonWithOneSection)
        // Assert
        expect(self.persister.loadMenus()).toEventually(equal(menusWithOneSection))
    }
    
    func test_persister_whenCleanDataBase_dbShouldBeEmpty() {
        // Arrange
        let menusJson = JSON.from(file: "menus_ok")
        let contentListJson = JSON.from(file: "contentlist_ok")
        // Act
        self.saveMenusAndSections(from: menusJson)
        self.saveContentAndActions(from: contentListJson, in: "/content/5853e73f71905538c7a36049")
        self.persister.cleanDataBase()
        // Assert
        let allObjectsCount = self.managedObjectModel.entities
            .flatMap({ $0.name })
            .map({ self.fetchAllObjects(of: $0, in: self.managedObjectContext).count })
            .reduce(0, {$0 + $1})
        expect(allObjectsCount).toEventually(equal(0))
    }
    
    func test_persister_whenThereAreContentsWithScheduleDate_andTheDateProvidedIsOutsideOfAContentScheduleDate_shouldFetchFromDataBaseTheCorrectContents() {
        // Arrange
        let menusJson = JSON.from(file: "menus_ok")
        let contentListJson = JSON.from(file: "contentlist_ok_with_two_contents")
        let contentList = try! ContentList.contentList(contentListJson)
        // Act
        self.saveMenusAndSections(from: menusJson)
        self.saveContentAndActions(from: contentListJson, in: "/content/5853e73f71905538c7a36049")
        // Assert
        let content = contentList.contents.first(where: { $0.slug == "COME-VIAGGIARE-IN-MODO-INTELLIGENTE-SENZA-SPENDERE-UN-CAPITALE-rycOB8vOx" })!
        let contents = self.persister.loadContentList(with: "/content/5853e73f71905538c7a36049", validAt: Date(timeIntervalSince1970: 1605618786))!.contents
        expect(contents).toEventuallyNot(contain(content))
    }
    
    func test_persister_whenThereAreContentsWithScheduleDate_andTheDateProvidedIsInsideOfAllContentScheduleDates_shouldFetchFromDataBaseAllContents() {
        // Arrange
        let menusJson = JSON.from(file: "menus_ok")
        let contentListJson = JSON.from(file: "contentlist_ok_with_two_contents")
        let contentList = try! ContentList.contentList(contentListJson)
        // Act
        self.saveMenusAndSections(from: menusJson)
        self.saveContentAndActions(from: contentListJson, in: "/content/5853e73f71905538c7a36049")
        // Assert
        let contents = self.persister.loadContentList(with: "/content/5853e73f71905538c7a36049", validAt: Date(timeIntervalSince1970: 1510924386))!.contents
        print(self.fetchAllObjects(of: "Element", in: self.managedObjectContext))
        expect(contents).toEventually(equal(contentList.contents))
    }

    // MARK: - Private methods
    
    private func fetchAllObjects(of entity: String, in context: NSManagedObjectContext?) -> [NSManagedObject] {
        var result: [NSManagedObject] = []
        context?.performAndWait({
            let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            guard let results = try? context?.fetch(fetch) else { return }
            result = results as! [NSManagedObject]
        })
        return result
    }
    
    private func saveMenusAndSections(from json: JSON) {
        guard
            let menuJson = json["data.menus"]
            else {
                return
        }
        
        let menus = menuJson.flatMap { try? Menu.menuList($0) }
        self.persister.save(menus: menus)
        var sectionsMenu: [[String]] = []
        for menu in menuJson {
            guard
                let menuModel = try? Menu.menuList(menu),
                let elements = menu["elements"]?.toArray() as? [NSDictionary],
                let elementsCache = json["data.elementsCache"]
                else {
                    return
            }
            // Sections to cache
            var sections = [String]()
            // Save sections in menu
            let jsonElements = elements.map({ JSON(from: $0) })
            self.persister.save(sections: jsonElements, in: menuModel.slug)
            for element in jsonElements {
                if let elementUrl = element["elementUrl"]?.toString(),
                    let elementCache = elementsCache["\(elementUrl)"] {
                    // Save each action in section
                    self.persister.save(action: elementCache, in: elementUrl)
                    if let sectionPath = elementCache["render"]?["contentUrl"]?.toString() {
                        sections.append(sectionPath)
                    }
                }
            }
            sectionsMenu.append(sections)
        }
    }
    
    private func saveContentAndActions(from json: JSON, in path: String) {
        let expirationDate = json["data.expireAt"]?.toDate()
        let contentVersion = json["data.contentVersion"]?.toString()
        // Save content in path
        self.persister.save(content: json, in: path, expirationDate: expirationDate, contentVersion: contentVersion)
        if let elementsCache = json["data.elementsCache"]?.toDictionary() {
            for (identifier, action) in elementsCache {
                // Save each action linked to content path
                self.persister.save(action: JSON(from: action), with: identifier)
            }
        }
    }
    
    private func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("ContentDB.sqlite")
        let options = [ NSInferMappingModelAutomaticallyOption: true,
                        NSMigratePersistentStoresAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: url, options: options)
        } catch let error {
            print(error)
        }
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return managedObjectContext
    }
}
