//
//  URLSchemeDelegate.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol enables the delegate to handle a scheme URL triggered in OCM.
///
/// - Since: 3.0
public protocol URLSchemeDelegate {
    
    /// Use this method to execute a custom action associated to a scheme URL.
    ///
    /// - parameter url: `URL` components for scheme to be launched.
    /// - Since: 3.0
    func openURLScheme(_ url: URLComponents)
}
//swiftlint:enable class_delegate_protocol
