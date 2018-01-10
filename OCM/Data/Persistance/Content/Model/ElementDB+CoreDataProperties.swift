//
//  ElementDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension ElementDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ElementDB> {
        return NSFetchRequest<ElementDB>(entityName: "Element")
    }

    @NSManaged public var slug: String?
    @NSManaged public var name: String?
    @NSManaged public var tags: NSData?
    @NSManaged public var customProperties: NSData?
    @NSManaged public var elementUrl: String?
    @NSManaged public var sectionView: NSData?
    @NSManaged public var orderIndex: Int64
    @NSManaged public var contentList: ContentListDB?
    @NSManaged public var scheduleDates: NSSet?

    // MARK: - CoreDataInstantiable
    
    static var entityName: String = "Element"
}

// MARK: Generated accessors for scheduleDates
extension ElementDB {

    @objc(addScheduleDatesObject:)
    @NSManaged public func addToScheduleDates(_ value: ScheduleDateDB)

    @objc(removeScheduleDatesObject:)
    @NSManaged public func removeFromScheduleDates(_ value: ScheduleDateDB)

    @objc(addScheduleDates:)
    @NSManaged public func addToScheduleDates(_ values: NSSet)

    @objc(removeScheduleDates:)
    @NSManaged public func removeFromScheduleDates(_ values: NSSet)

}
