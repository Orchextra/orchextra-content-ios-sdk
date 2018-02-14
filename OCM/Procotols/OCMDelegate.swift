//
//  OCMDelegate.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//
//swiftlint:disable class_delegate_protocol

import Foundation


/**
 This protocol is used to comunicate OCM with integrative application.
 
 - Since: 1.0
 */

public protocol OCMDelegate {
    
    /**
     Use this method to execute a custom action associated to an url.
     
     - parameter url: The url to be launched.
     - Since: 1.0
     */
    func customScheme(_ url: URLComponents)
    
    
    /**
     Use this method to notify that content has been opened.
     
     - parameter identifier: The content identifier that has been opened.
     - Since: 1.0
     */
    func userDidOpenContent(with identifier: String)
    
    /**
     Use this method to notify that menus have been updated.
     
     - Parameter menus: The menus
     - Since: 2.0.0
     */
    func menusDidRefresh(_ menus: [Menu])
    
    /**
     Implement this method to authenticate user for federated authorization.
     
     - Parameter federated: Dictionary with information for obtaining federated token.
     - Paremeter completion: Completion block triggered to authenticate user with federated token.
     - Since: 2.0.1
     */
    func federatedAuthentication(_ federated: [String: Any], completion: @escaping ([String: Any]?) -> Void)
    
}
//swiftlint:enable class_delegate_protocol

public extension OCMDelegate {
    func federatedAuthentication(_ federated: [String: Any], completion: @escaping ([String: Any]?) -> Void) {}
}
