//
//  ElementDB+CoreDataClass.swift
//  OCM
//
//  Created by José Estela on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import GIGLibrary
import CoreData

@objc(ElementDB)
public class ElementDB: NSManagedObject {
    
    func toContent() -> Content? {
        guard
            let elementUrl = self.elementUrl,
            let slug = self.slug,
            let sectionView = self.sectionView as Data?,
            let media = NSKeyedUnarchiver.unarchiveObject(with: sectionView) as? Media,
            let requiredAuth = self.requiredAuth,
            let tagsData = self.tags as Data?,
            let tags = NSKeyedUnarchiver.unarchiveObject(with: tagsData) as? [String]
        else {
            return nil
        }
        return Content(slug: slug, tags: tags, name: self.name, media: media, elementUrl: elementUrl, requiredAuth: requiredAuth)
    }
}
