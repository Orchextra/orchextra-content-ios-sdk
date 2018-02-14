//
//  ParameterCustomizationDelegate.swift
//  OCM
//
//  Created by José Estela on 7/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol allow the delegate to handle the parameters of actions that need customization
/// - Since: 3.0.0
public protocol ParameterCustomizationDelegate {
    
    /// This method tells the delegate that an action needs some values for the following parameters
    ///
    /// - Parameter parameters: The parameter keys
    /// - Returns: The values for the given parameters
    /// - Since: 3.0.0
    func actionNeedsValues(for parameters: [String]) -> [String: String?]
}

//swiftlint:enable class_delegate_protocol
