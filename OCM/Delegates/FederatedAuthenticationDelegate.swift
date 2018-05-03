//
//  FederatedAuthenticationDelegate.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 15/02/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol is used for federated authentication.
///
/// - Since: 3.0
public protocol FederatedAuthenticationDelegate {
    
    /// Implement this method to authenticate user for federated authorization.
    ///
    /// - Parameter federated: Dictionary with information for obtaining federated token.
    /// - Paremeter completion: Completion block triggered to authenticate user with federated token.
    /// - Since: 3.0
    func federatedAuthentication(_ federated: [String: Any], completion: @escaping ([String: Any]?) -> Void)
    
}
//swiftlint:enable class_delegate_protocol
