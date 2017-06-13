//
//  ContentDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 12/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension ContentDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentDB> {
        return NSFetchRequest<ContentDB>(entityName: "Content")
    }

    @NSManaged public var path: String?
    @NSManaged public var value: String?
    @NSManaged public var actionOwner: ActionDB?
    @NSManaged public var actions: NSSet?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "Content"
}



// MARK: Generated accessors for actions
extension ContentDB {
    
    @objc(addActionsObject:)
    @NSManaged public func addToActions(_ value: ActionDB)
    
    @objc(removeActionsObject:)
    @NSManaged public func removeFromActions(_ value: ActionDB)
    
    @objc(addActions:)
    @NSManaged public func addToActions(_ values: NSSet)
    
    @objc(removeActions:)
    @NSManaged public func removeFromActions(_ values: NSSet)
    
}

