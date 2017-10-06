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
            
            return Video(
                source: "",   // TODO EDU, para que se usa source?
                format: VideoFormat.vimeo,
                previewUrl: "https://i.vimeocdn.com/video/\(previewUrl)_1280x720.jpg?r=pad", // TODO EDU, hay que cambiar la resolucion por lo que tenga de pantalla
                videoUrl: urlActual
            )
        } else {
            throw ParseError.json
        }
    }
}
