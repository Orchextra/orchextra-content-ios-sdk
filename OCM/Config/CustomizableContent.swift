//
//  CustomizableContent.swift
//  OCM
//
//  Created by José Estela on 23/1/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

open class CustomizableContent {
    
    let identifier: String
    open let customProperties: [String: Any]
    open let viewType: ViewType
    open var customizations: [ViewCustomizationType] = []
    
    init(identifier: String, customProperties: [String: Any], viewType: ViewType) {
        self.identifier = identifier
        self.customProperties = customProperties
        self.viewType = viewType
    }
    
}
