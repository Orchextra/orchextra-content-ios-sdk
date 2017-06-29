//
//  ActionDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension ActionDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActionDB> {
        return NSFetchRequest<ActionDB>(entityName: "Action")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var value: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var section: SectionDB?
    @NSManaged public var contentOwners: NSSet?
    @NSManaged public var content: ContentDB?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "Action"

}
    
// MARK: Generated accessors for contentOwners
extension ActionDB {
    
    @objc(addContentOwnersObject:)
    @NSManaged public func addToContentOwners(_ value: ContentDB)
    
    @objc(removeContentOwnersObject:)
    @NSManaged public func removeFromContentOwners(_ value: ContentDB)
    
    @objc(addContentOwners:)
    @NSManaged public func addToContentOwners(_ values: NSSet)
    
    @objc(removeContentOwners:)
    @NSManaged public func removeFromContentOwners(_ values: NSSet)
    
}
