//
//  Content.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


enum Layout {
    case carousel
    case mosaic
}


enum ParseError: Error {
    case json
}


struct Content {
    
    let id: String
    var media: Media
    let action: Action?
	
	
	// MARK: - Factory Methods
	
	static func content(from json: JSON) -> Content? {
		guard let media = json["sectionView"].flatMap(Media.media) else {
			LogWarn("Content has no sectionView")
			return nil
		}
		
		let content = Content(
			id: json["slug"]?.toString() ?? "\(Date().timeIntervalSince1970)",
			media: media,
			action: json["action"].flatMap(ActionFactory.action)
		)
		
		return content
	}

}

func == (lhs: Content, rhs: Content) -> Bool {
	return lhs.id == rhs.id
}
