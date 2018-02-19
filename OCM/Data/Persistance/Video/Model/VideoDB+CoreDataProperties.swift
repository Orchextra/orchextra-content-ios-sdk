//
//  VideoDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 19/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension VideoDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoDB> {
        return NSFetchRequest<VideoDB>(entityName: "Video")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var url: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var type: String?
    @NSManaged public var updatedAt: NSDate?

    static var entityName: String = "Video"
}
