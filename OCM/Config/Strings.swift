//
//  Strings.swift
//  OCM
//
//  Created by José Estela on 6/7/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/// Use this struct to customize strings that OCM needs to display in some cases
public struct Strings {
    
    // MARK: - Public init
    
    public init() {
        self.internetConnectionRequired = localize("error_no_internet")
    }
    
    public init(internetConnectionRequired: String) {
        self.internetConnectionRequired = internetConnectionRequired
    }
    
    /**
     Set the string of the alert that is showed when a content requires internet.
    */
    public let internetConnectionRequired: String
    
}
