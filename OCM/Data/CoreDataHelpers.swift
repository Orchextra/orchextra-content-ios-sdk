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
        guard
            let managedObjectContext = context,
            let entity = NSEntityDescription.entity(forEntityName: T.entityName, in: managedObjectContext)
        else {
            return nil
        }
        return NSManagedObject(entity: entity, insertInto: managedObjectContext) as? T
    }
    
    static func from(_ context: NSManagedObjectContext?, with predicateFormat: String, _ args: CVarArg) -> T? {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName)
        fetch.predicate = NSPredicate(format: predicateFormat, args)
        guard
            let results = try? context?.fetch(fetch),
            let resultsManagedObject = results as? [NSManagedObject]
        else {
            return nil
        }
        if resultsManagedObject.indices.contains(0) {
            return resultsManagedObject[0] as? T
        }
        return nil
    }
}


struct CoreDataArray<T: CoreDataInstantiable> {
    
    static func from(_ context: NSManagedObjectContext?) -> [T]? {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName)
        guard
            let results = try? context?.fetch(fetch)
        else {
            return nil
        }
        return results as? [T]
    }
    
    static func from(_ context: NSManagedObjectContext?, with predicateFormat: String, _ args: CVarArg) -> [T]? {
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: T.entityName)
        fetch.predicate = NSPredicate(format: predicateFormat, args)
        guard
            let results = try? context?.fetch(fetch)
        else {
            return nil
        }
        return results as? [T]
    }
}
