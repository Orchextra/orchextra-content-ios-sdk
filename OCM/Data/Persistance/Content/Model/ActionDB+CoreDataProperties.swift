//
//  ActionDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 14/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension ActionDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActionDB> {
        return NSFetchRequest<ActionDB>(entityName: "Action")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var value: String?
    @NSManaged public var customProperties: NSData?
    @NSManaged public var content: ContentListDB?
    @NSManaged public var element: ElementDB?
    @NSManaged public var section: SectionDB?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "Action"

}
