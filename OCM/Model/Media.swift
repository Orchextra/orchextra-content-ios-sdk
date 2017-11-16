//
//  Media.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


class Media: NSObject, NSCoding {
    let url: String?
    let thumbnail: Data?
    
    init(url: String?, thumbnail: Data?) {
        self.url = url
        self.thumbnail = thumbnail
    }
	
	static func media(from json: JSON) -> Media? {
        let url = json["imageUrl"]?.toString()
        let thumbnail = json["imageThumb"]?.toString() ?? ""
        let thumbnailData = Data(base64Encoded: thumbnail)

        return Media(url: url, thumbnail: thumbnailData)
	}
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.url, forKey: "url")
        aCoder.encode(self.thumbnail, forKey: "thumbnail")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.url = aDecoder.decode(for: "url")
        self.thumbnail = aDecoder.decode(for: "thumbnail")
    }
}
