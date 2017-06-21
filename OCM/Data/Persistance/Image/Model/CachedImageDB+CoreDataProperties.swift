//
//  CachedImageDB+CoreDataProperties.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 20/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension CachedImageDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedImageDB> {
        return NSFetchRequest<CachedImageDB>(entityName: "StoredImage")
    }

    @NSManaged public var filename: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var dependencies: NSSet?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "StoredImage"
}

// MARK: Generated accessors for dependencies
extension CachedImageDB {

    @objc(addDependenciesObject:)
    @NSManaged public func addToDependencies(_ value: ImageDependencyDB)

    @objc(removeDependenciesObject:)
    @NSManaged public func removeFromDependencies(_ value: ImageDependencyDB)

    @objc(addDependencies:)
    @NSManaged public func addToDependencies(_ values: NSSet)

    @objc(removeDependencies:)
    @NSManaged public func removeFromDependencies(_ values: NSSet)

}
