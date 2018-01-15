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
    
    /// Method to map the required authorization value from V2 to it's correspondant custom property rule in V3.
    ///
    /// - Parameters:
    ///   - requiredAuthorization: The source value for required authorization.
    ///
    /// - Returns: Binary data for the custom property rule.
    @objc func mapToCustomProperties(from requiredAuthorization: String) -> NSData {
        
        let customProperty = NSKeyedArchiver.archivedData(withRootObject: ["requiredAuth": requiredAuthorization]) as NSData
        return customProperty
    }
}
