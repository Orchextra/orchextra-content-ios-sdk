//
//  MenuDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension MenuDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MenuDB> {
        return NSFetchRequest<MenuDB>(entityName: "Menu")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var sections: NSSet?
}
