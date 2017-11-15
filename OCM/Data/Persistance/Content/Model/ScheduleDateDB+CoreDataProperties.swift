//
//  ScheduleDateDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension ScheduleDateDB: CoreDataInstantiable {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleDateDB> {
        return NSFetchRequest<ScheduleDateDB>(entityName: "ScheduleDate")
    }

    @NSManaged public var end: NSDate?
    @NSManaged public var start: NSDate?
    @NSManaged public var element: ElementDB?
    
    // MARK: - CoreDataInstantiable
    
    static var entityName: String = "ScheduleDate"

}
