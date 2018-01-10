//
//  ElementV2toV3MigrationPolicy.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 10/01/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData

class ElementV2toV3MigrationPolicy: NSEntityMigrationPolicy {
    
    /// Method to !!!
    @objc func mapToCustomProperties(from requiredAuthorization: String) -> NSData {
        
        let customProperty = NSKeyedArchiver.archivedData(withRootObject: ["requiredAuth": requiredAuthorization]) as NSData
        return customProperty
    }
}
