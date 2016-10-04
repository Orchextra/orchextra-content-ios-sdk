//
//  Media.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct Media {
    let url: String
    var image: UIImage?
    let width: Int?
    let height: Int?
    
    init(url: String, width: Int? = nil, height: Int? = nil) {
        self.url = url
        self.width = width
        self.height = height
    }
    
    init(json: JSON) throws {
        guard
            let mediaJson = json["data"]?[0]
            else { throw ParseError.json }
        
        self.init(
            url: mediaJson["media_url"]?.toString() ?? "null",
            width: mediaJson["width"]?.toInt(),
            height: mediaJson["height"]?.toInt()
        )
    }
    
}
