//
//  ScheduleDateDB+CoreDataClass.swift
//  OCM
//
//  Created by José Estela on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ScheduleDateDB)
public class ScheduleDateDB: NSManagedObject {

    func toContentDate() -> ContentDate? {
        guard
            let start = self.start as Date?,
            let end = self.end as Date?
        else {
            return nil
        }
        return ContentDate(start: start, end: end)
    }
    
}
