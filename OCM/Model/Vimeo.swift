//
//  Vimeo.swift
//  OCM
//
//  Created by eduardo parada pardo on 6/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class Vimeo: Video {
    
    class func parseVideo(identifier: String, json: JSON) throws -> Video {
        
        guard
            let pictures = json["pictures"]?.toDictionary(),
            let uri = pictures["uri"] as? String,
            var files = json["files"]?.toArray() as? [[AnyHashable: Any]]
            else {
                LogWarn("Missing pictures, uri or files")
                throw ParseError.json
        }
        
        var videoURL: String?
    
        files = files.sorted(by: {
            if let width0 = $0["width"] as? Int, let width1 = $1["width"] as? Int {
                return width0 > width1
            }
            return false
        })
        
        if ReachabilityWrapper.shared.isReachableViaWiFi() {
            if let url = files[0]["link_secure"] as? String {
                videoURL = url
            }
        } else {
            if let url = files.last?["link_secure"] as? String {
                videoURL = url
            }
        }
        
        let urlList = uri.components(separatedBy: "/")
        if urlList.count > 4 {
            let previewUrl = urlList[4]
            let width = UIScreen.main.bounds.width * 2
            let height = width * 9/16
            
            return Video(
                source: identifier,
                format: VideoFormat.vimeo,
                previewUrl: "https://i.vimeocdn.com/video/\(previewUrl)_\(Int(width))x\(Int(height)).jpg?r=pad",
                videoUrl: videoURL
            )
        } else {
            throw ParseError.json
        }
    }
}
