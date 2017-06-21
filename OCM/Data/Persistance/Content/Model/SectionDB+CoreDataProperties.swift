//
//  SectionDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 21/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension SectionDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionDB> {
        return NSFetchRequest<SectionDB>(entityName: "Section")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var orderIndex: Int64
    @NSManaged public var value: String?
    @NSManaged public var actions: NSSet?
    @NSManaged public var menu: MenuDB?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "Section"

}

// MARK: Generated accessors for actions
extension SectionDB {

    @objc(addActionsObject:)
    @NSManaged public func addToActions(_ value: ActionDB)

    @objc(removeActionsObject:)
    @NSManaged public func removeFromActions(_ value: ActionDB)

    @objc(addActions:)
    @NSManaged public func addToActions(_ values: NSSet)

    @objc(removeActions:)
    @NSManaged public func removeFromActions(_ values: NSSet)

}
