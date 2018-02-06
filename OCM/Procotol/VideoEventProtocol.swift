//
//  VideoEventProtocol.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//
//swiftlint:disable class_delegate_protocol

import Foundation

/**
 This protocol informs about video events that occurs in OCM
 -  Since: 2.1.4
 */

public protocol OCMVideoEventDelegate {
    /**
     Event triggered when a video starts or resumes
     */
    func videoDidStart(identifier: String)
    /**
     Event triggered when a video stops
     */
    func videoDidStop(identifier: String)
    /**
     Event triggered when a video pauses (restricted to >= iOS 10 when OCM plays vimeo videos)
     */
    func videoDidPause(identifier: String)
}

//swiftlint:enable class_delegate_protocol
