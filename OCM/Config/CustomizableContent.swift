//
//  CustomizableContent.swift
//  OCM
//
//  Created by José Estela on 23/1/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

open class CustomizableContent: Hashable {
    
    let identifier: String
    public let customProperties: [String: Any]
    public let viewType: ViewType
    open var customizations: [ViewCustomizationType] = []
    
    public func hash(into hasher: inout Hasher) {
        self.identifier.hash(into: &hasher)
    }
    
    init(identifier: String, customProperties: [String: Any], viewType: ViewType) {
        self.identifier = identifier
        self.customProperties = customProperties
        self.viewType = viewType
    }
    
    public static func == (lhs: CustomizableContent, rhs: CustomizableContent) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
