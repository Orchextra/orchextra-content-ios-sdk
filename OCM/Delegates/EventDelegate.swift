//
//  EventDelegate.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol informs the delegate about OCM's events of interest.
///
/// - Since: 3.0
public protocol EventDelegate {
    
    /// Event triggered when the preview for a content loads on display.
    ///
    /// - Parameter identifier: `String` representation for content's identifier.
    /// - Parameter type: `String` representation for content's type.
    /// - Since: 3.0
    func contentPreviewDidLoad(identifier: String, type: String)
   
    /// Event triggered when a content loads on display.
    ///
    /// - Parameter identifier: `String` representation for content's identifier.
    /// - Parameter type: `String` representation for content's type.
    /// - Since: 3.0
    func contentDidLoad(identifier: String, type: String)
    
    /// Event triggered when a content is shared by the user.
    ///
    /// - Parameter identifier: `String` representation for content's identifier.
    /// - Parameter type: `String` representation for content's type.
    /// - Since: 3.0
    func userDidShareContent(identifier: String, type: String)
    
    /// Event triggered when a content is opened by the user.
    ///
    /// - Parameter identifier: `String` representation for content's identifier.
    /// - Parameter type: `String` representation for content's type.
    /// - Since: 3.0
    func userDidOpenContent(identifier: String, type: String)
    
    /// Event triggered when a video loads.
    ///
    /// - Parameter identifier: `String` representation for video's identifier.
    /// - Since: 3.0
    func videoDidLoad(identifier: String)
    
    /// Event triggered when a section loads on display.
    ///
    /// - Parameter section: object for the loaded section.
    /// - Since: 3.0
    func sectionDidLoad(_ section: Section)
}
//swiftlint:enable class_delegate_protocol
