//
//  ContentDB+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 12/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension ContentDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentDB> {
        return NSFetchRequest<ContentDB>(entityName: "Content")
    }

    @NSManaged public var path: String?
    @NSManaged public var value: String?
    @NSManaged public var action: ActionDB?

}
