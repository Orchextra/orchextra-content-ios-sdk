//
//  Video.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

enum VideoFormat: String {
    case youtube
    case vimeo
    
    static func from(_ string: String) -> VideoFormat? {
        switch string {
        case "youtube":
            return .youtube
        case "vimeo":
            return .vimeo
        default:
            return nil
        }
    }
}

class Video: Equatable {
    
    // MARK: - Public attributes
    
    let source: String
    let format: VideoFormat
    var previewUrl: String?
    var videoUrl: String?
    
    init(source: String, format: VideoFormat, previewUrl: String? = nil, videoUrl: String? = nil) {
        self.source = source
        self.format = format
        self.previewUrl = previewUrl
        self.videoUrl = videoUrl
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.source == rhs.source
    }
}
