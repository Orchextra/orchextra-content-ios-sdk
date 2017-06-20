//
//  ImageDependencyDB+CoreDataProperties.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 20/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData


extension ImageDependencyDB: CoreDataInstantiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageDependencyDB> {
        return NSFetchRequest<ImageDependencyDB>(entityName: "ImageDependency")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var images: NSSet?
    
    // MARK: - CoreDataInstantiable
    
    static let entityName: String = "ImageDependency"

}

// MARK: Generated accessors for images
extension ImageDependencyDB {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: CachedImageDB)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: CachedImageDB)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
