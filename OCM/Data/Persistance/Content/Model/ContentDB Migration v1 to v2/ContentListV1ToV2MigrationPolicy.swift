//
//  ContentMigrationPolicy.swift
//  OCM
//
//  Created by José Estela on 20/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import CoreData

class ContentListV1ToV2MigrationPolicy: NSEntityMigrationPolicy {
    
    /// Method to create the destination instance of the Content entity
    ///
    /// - Parameters:
    ///   - sInstance: The source instance (Content)
    ///   - mapping: The mapping
    ///   - manager: The migration manager
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        guard
            let contentValue = sInstance.value(forKey: "value") as? String,
            let json = JSON.fromString(contentValue),
            let content = try? ContentList.contentList(json),
            let entityName = mapping.destinationEntityName
        else {
            return
        }
        // Create a new ContentListDB object and set data from the old instance of ContentDB
        let contentListDB = NSEntityDescription.insertNewObject(forEntityName: entityName, into: manager.destinationContext)
        contentListDB.setValue(json["expireAt"]?.toDate() as NSDate?, forKey: "expirationDate")
        contentListDB.setValue(json["content.layout"]?.stringRepresentation(), forKey: "layout")
        contentListDB.setValue(json["content.slug"]?.toString(), forKey: "slug")
        contentListDB.setValue(json["content.tags"]?.toString()?.data(using: .utf8) as NSData?, forKey: "tags")
        contentListDB.setValue(json["content.type"]?.toString(), forKey: "type")
        contentListDB.setValue(sInstance.value(forKey: "path"), forKey: "path")
        let setOfElements = NSMutableSet()
        // Iterate into Contents and generate the ElementDB and ScheduleDateDB
        for (index, content) in content.contents.enumerated() {
            let element = NSEntityDescription.insertNewObject(forEntityName: "Element", into: manager.destinationContext)
            element.setValue(Int64(index), forKey: "orderIndex")
            element.setValue(content.name, forKey: "name")
            element.setValue(content.slug, forKey: "slug")
            element.setValue(content.elementUrl, forKey: "elementUrl")
            element.setValue(NSKeyedArchiver.archivedData(withRootObject: content.tags) as NSData?, forKey: "tags")
            element.setValue(NSKeyedArchiver.archivedData(withRootObject: content.media) as NSData?, forKey: "sectionView")
            element.setValue(content.requiredAuth, forKey: "requiredAuth")
            if let dates = content.dates {
                let setOfDates = NSMutableSet()
                dates.forEach { date in
                    let scheduleDate = NSEntityDescription.insertNewObject(forEntityName: "ScheduleDate", into: manager.destinationContext)
                    scheduleDate.setValue(date.start as NSDate?, forKey: "start")
                    scheduleDate.setValue(date.end as NSDate?, forKey: "end")
                    setOfDates.add(scheduleDate)
                }
                element.setValue(setOfDates, forKey: "scheduleDates")
            }
            setOfElements.add(element)
        }
        contentListDB.setValue(setOfElements, forKey: "elements")
        // Associate old with new instance
        manager.associate(sourceInstance: sInstance, withDestinationInstance: contentListDB, for: mapping)
    }
    
}
