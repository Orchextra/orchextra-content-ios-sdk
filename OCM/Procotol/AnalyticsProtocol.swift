//
//  AnalyticsProtocol.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

/**
 This protocol is used to track information in analytics framweworks.
 
 - Since: 1.0
 */
public protocol OCMAnalytics {
    
    /**
     Use this method to track an event in analytics framworks.
     
     - parameter info: The info to be tracked.
     - Since: 1.0
     */
    func track(with info: [String: Any?])
}
