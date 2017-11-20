//
//  Content+CoreDataProperties.swift
//  OCM
//
//  Created by José Estela on 14/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content")
    }

    @NSManaged public var contentList: ContentDB?

}
