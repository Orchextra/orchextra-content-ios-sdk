//
//  EventProtocol.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//
//swiftlint:disable class_delegate_protocol

import Foundation


/**
 This protocol informs about OCM's events of interest.
 
 - Since: 2.1.0
 */

public protocol OCMEventDelegate {
    
    /**
     Event triggered when the preview for a content loads on display.
     
     - Parameter identifier: `String` representation for content's identifier.
     - Parameter type: `String` representation for content's type.
     - Since: 2.1.0
     */
    func contentPreviewDidLoad(identifier: String, type: String)
    
    /**
     Event triggered when a content loads on display.
     
     - Parameter identifier: `String` representation for content's identifier.
     - Parameter type: `String` representation for content's type.
     - Since: 2.1.0
     */
    func contentDidLoad(identifier: String, type: String)
    
    /**
     Event triggered when a content is shared by the user.
     
     - Parameter identifier: `String` representation for content's identifier.
     - Parameter type: `String` representation for content's type.
     - Since: 2.1.0
     */
    func userDidShareContent(identifier: String, type: String)
    
    /**
     Event triggered when a content is opened by the user.
     
     - Parameter identifier: `String` representation for content's identifier.
     - Parameter type: `String` representation for content's type.
     - Since: 2.1.0
     */
    func userDidOpenContent(identifier: String, type: String)
    
    /**
     Event triggered when a video loads.
     
     - Parameter identifier: `String` representation for video's identifier.
     - Since: 2.1.0
     */
    func videoDidLoad(identifier: String)
    
    /**
     Event triggered when a section loads on display.
     
     - Parameter section: object for the loaded section.
     - Since: 2.1.0
     */
    func sectionDidLoad(_ section: Section)
}

//swiftlint:enable class_delegate_protocol
