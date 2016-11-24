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
    let url: String?
    let thumbnail: Data?
	
	static func media(from json: JSON) -> Media? {
        let url = json["imageUrl"]?.toString()
        let thumbnail = json["imageThumb"]?.toString() ?? ""
        let thumbnailData = Data(base64Encoded: thumbnail)

        return Media(url: url, thumbnail: thumbnailData)
	}
}
