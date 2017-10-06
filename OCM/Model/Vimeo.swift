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
    
    class func parseVideo(json: JSON) throws -> Video {
        
        guard
            let pictures = json["pictures"]?.toDictionary(),
            let uri = pictures["uri"] as? String,
            let listVideos = json["files"]?.toArray() as? [[AnyHashable: Any]]
            else {
                logWarn("Missing pictures, uri or files")
                throw ParseError.json
        }
        
        var urlActual = ""
        var widthActual = 0
        
        for video in listVideos {  // TODO EDU hay q meter logica para ver lo de la wifi o q hacer con ello
            if let width = video["width"] as? Int,
                let url = video["link_secure"] as? String ,
                widthActual < width {
                    widthActual = width
                    urlActual = url
            }
        }
        
        let urlList = uri.components(separatedBy: "/")
        if urlList.count > 4 {
            let previewUrl = urlList[4]
            let width = UIScreen.main.bounds.width*2
            let height = width*9/16
            
            return Video(
                source: "",
                format: VideoFormat.vimeo,
                previewUrl: "https://i.vimeocdn.com/video/\(previewUrl)_\(Int(width))x\(Int(height)).jpg?r=pad",
                videoUrl: urlActual
            )
        } else {
            throw ParseError.json
        }
    }
}
