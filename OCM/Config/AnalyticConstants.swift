//
//  AnalyticConstants.swift
//  OCM
//
//  Created by José Estela on 13/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct AnalyticConstants {
    // KEYS
    static let kAction = "ACTION"
    static let kCategory = "CATEGORY" // The section of the content
    static let kValue = "VALUE" // Value (id or similar)
    static let kType = "TYPE" // Type of event (screen, tap, access)
    static let kContentType = "CONTENT_TYPE" // The type of the content
    
    // TYPES
    static let kScreen = "SCREEN"
    static let kTap = "TAP"
    static let kAccess = "ACCESS"
    
    // TAGS (ACTION)
    static let kContent = "CONTENT"
    static let kSharing = "SHARING"
    static let kPreview = "PREVIEW"
}
