//
//  SectionDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension SectionDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionDB> {
        return NSFetchRequest<SectionDB>(entityName: "Section")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var value: String?
    @NSManaged public var actions: NSSet?
    @NSManaged public var menu: MenuDB?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "Section"

}
