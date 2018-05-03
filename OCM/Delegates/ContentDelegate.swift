//
//  ContentDelegate.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 15/02/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol allows the delegate to react to changes in the content handled by OCM.
///
/// - Since: 3.0
public protocol ContentDelegate {
    
    /// Implement this method to react after the user opens a content.
    ///
    /// - parameter identifier: `String` representation of the identifier for the opened content.
    /// - Since: 3.0
    func userDidOpenContent(with identifier: String)
    
    /// Implement this method to react after the menus have been updated.
    ///
    /// - Parameter menus: Updated menus.
    /// - Since: 3.0
    func menusDidRefresh(_ menus: [Menu])
    
}
//swiftlint:enable class_delegate_protocol
