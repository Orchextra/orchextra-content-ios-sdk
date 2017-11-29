//
//  SectionDB+CoreDataClass.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData
import GIGLibrary

@objc(SectionDB)
public class SectionDB: NSManagedObject {
    
    // MARK: - Transformation method
    
    /// Transform a SectionBD into a Section model
    ///
    /// - Returns: The section if all values are correctly retrieve from db
    func toSection() -> Section? {
        guard let value = self.value, let json = JSON.fromString(value) else { return nil }
        return Section.parseSection(json: json)
    }
}
