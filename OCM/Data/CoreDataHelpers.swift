//
//  CoreDataHelpers.swift
//  OCM
//
//  Created by José Estela on 13/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataInstantiable {
    static var entityName: String { get }
}

struct CoreDataObject<T: CoreDataInstantiable> {
    
    static func create(insertingInto context: NSManagedObjectContext?) -> T? {
        var result: T?
        context?.performAndWait({
            guard
                let managedObjectContext = context,
                let entity = NSEntityDescription.entity(forEntityName: T.entityName, in: managedObjectContext)
                else {
                    return
            }
            result = NSManagedObject(entity: entity, insertInto: managedObjectContext) as? T
        })
        return result
    }
    
    static func from(_ context: NSManagedObjectContext?, with predicateFormat: String, arguments args: [Any]) -> T? {
        var result: T?
        context?.performAndWait({
            let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName)
            fetch.predicate = NSPredicate(format: predicateFormat, argumentArray: args)
            guard
                let results = try? context?.fetch(fetch),
                let resultsManagedObject = results as? [NSManagedObject]
                else {
                    return
            }
            if resultsManagedObject.indices.contains(0) {
                result = resultsManagedObject[0] as? T
            }
        })
        return result
    }
}

struct CoreDataArray<T: CoreDataInstantiable> {
    
    static func from(_ context: NSManagedObjectContext?) -> [T]? {
        var result: [T]?
        context?.performAndWait({
            let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName)
            guard let fetchResult = try? context?.fetch(fetch) else {
                result = nil
                return
            }
            result = fetchResult as? [T]
        })
        return result
    }
    
    static func from(_ context: NSManagedObjectContext?, with predicateFormat: String, arguments args: [Any]) -> [T]? {
        var result: [T]?
        context?.performAndWait({
            let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName)
            fetch.predicate = NSPredicate(format: predicateFormat, argumentArray: args)
            guard
                let results = try? context?.fetch(fetch)
            else {
                return
            }
            result = results as? [T]
        })
        return result
    }
}
