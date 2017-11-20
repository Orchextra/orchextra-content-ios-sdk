//
//  ContentDate+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 14/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension ContentDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentDate> {
        return NSFetchRequest<ContentDate>(entityName: "ContentDate")
    }

    @NSManaged public var start: NSDate?
    @NSManaged public var end: NSDate?
    @NSManaged public var content: Content?

}
