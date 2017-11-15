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
        guard let value = self.value, let json = JSON.fromString(value) else { return nil }
        return Content.parseContent(from: json)
    }
}
