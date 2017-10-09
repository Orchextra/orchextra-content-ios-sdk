//
//  Providers.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/// Use this class to set credentials for OCM's integrated services and providers
public class Providers {
    
    /// Provider for Vimeo services.
    public var vimeo: VimeoProvider?
    
    public init() {}
   
}

/// Credentials for Vimeo
public struct VimeoProvider {
    
    /// Access token for consuming Vimeo's API
    public let accessToken: String
    
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
}
