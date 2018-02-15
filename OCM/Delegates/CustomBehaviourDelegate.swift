//
//  CustomBehaviourDelegate.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol allows the delegate to handle the behaviour of contents with custom properties, i.e.: property validation and how to display the content.
///
///  - Since: 3.0
public protocol CustomBehaviourDelegate {
    
    /// This method tells the delegate that a content with custom properties have to be validated/evaluated.
    ///
    /// - Parameter customProperties: Dictionary with custom properties information.
    /// - Parameter completion: Completion block to be triggered when content custom properties are validated, receives a `Bool` value representing the validation status, `true` for a succesful validation, otherwise `false`.
    /// - Since: 3.0
    func contentNeedsValidation(for customProperties: [String: Any], completion: @escaping (Bool) -> Void)
    
    
    /// This method tells the delegate that a content with custom properties might need a view transformation to be applied.
    /// - Parameter content: Customizable content
    /// - Parameter completion: Completion block to be triggered when content custom properties are validated, receives a `CustomizableContent` value.
    /// - Since: 2.1.8
    func contentNeedsCustomization(_ content: CustomizableContent, completion: @escaping (CustomizableContent) -> Void)
}
//swiftlint:enable class_delegate_protocol
