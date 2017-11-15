//
//  ContentListDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension ContentListDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentListDB> {
        return NSFetchRequest<ContentListDB>(entityName: "ContentList")
    }

    @NSManaged public var expirationDate: NSDate?
    @NSManaged public var path: String?
    @NSManaged public var elementsCache: String?
    @NSManaged public var slug: String?
    @NSManaged public var type: String?
    @NSManaged public var tags: NSData?
    @NSManaged public var layout: String?
    @NSManaged public var actionOwner: ActionDB?
    @NSManaged public var actions: NSSet?
    @NSManaged public var elements: NSSet?

    // MARK: - CoreDataInstantiable
    
    static var entityName: String = "ContentList"
}

// MARK: Generated accessors for actions
extension ContentListDB {

    @objc(addActionsObject:)
    @NSManaged public func addToActions(_ value: ActionDB)

    @objc(removeActionsObject:)
    @NSManaged public func removeFromActions(_ value: ActionDB)

    @objc(addActions:)
    @NSManaged public func addToActions(_ values: NSSet)

    @objc(removeActions:)
    @NSManaged public func removeFromActions(_ values: NSSet)

}

// MARK: Generated accessors for elements
extension ContentListDB {

    @objc(addElementsObject:)
    @NSManaged public func addToElements(_ value: ElementDB)

    @objc(removeElementsObject:)
    @NSManaged public func removeFromElements(_ value: ElementDB)

    @objc(addElements:)
    @NSManaged public func addToElements(_ values: NSSet)

    @objc(removeElements:)
    @NSManaged public func removeFromElements(_ values: NSSet)

}
