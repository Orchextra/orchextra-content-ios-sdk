//
//  Strings.swift
//  OCM
//
//  Created by José Estela on 6/7/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/// Use this struct to customize strings that OCM need to display in some cases
public struct Strings {
    
    // MARK: - Public init
    
    public init(internetConnectionRequired: String) {
        self.internetConnectionRequired = internetConnectionRequired
    }
    
    // MARK: - Strings
    
    /**
     Set the string of the alert that is showed when a content requires internet.
    */
    public var internetConnectionRequired: String = localize("error_no_internet")
    
}
