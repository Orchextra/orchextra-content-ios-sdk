//
//  VideoEventDelegate.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol

/// This protocol informs about video events that take place in OCM
///
/// - Since: 3.0
public protocol VideoEventDelegate {
    
    /// Event triggered when a video starts or resumes.
    ///
    /// - Parameter identifier: `String` representation of the identifier for the video.
    /// - Since: 3.0
    func videoDidStart(identifier: String)
    
    ///  Event triggered when a video stops
    ///
    /// - Parameter identifier: `String` representation of the identifier for the video.
    /// - Since: 3.0
    func videoDidStop(identifier: String)
    
    /// Event triggered when a video pauses (restricted to >= iOS 10 when OCM plays Vimeo videos),
    ///
    /// - Parameter identifier: `String` representation of the identifier for the video.
    /// - Since: 3.0
    func videoDidPause(identifier: String)
}
//swiftlint:enable class_delegate_protocol
