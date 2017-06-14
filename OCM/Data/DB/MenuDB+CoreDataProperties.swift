//
//  MenuDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension MenuDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuDB> {
        return NSFetchRequest<MenuDB>(entityName: "Menu")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var sections: NSSet?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "Menu"
}

// MARK: Generated accessors for sections
extension MenuDB {
    
    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: SectionDB)
    
    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: SectionDB)
    
    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)
    
    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)
    
}
