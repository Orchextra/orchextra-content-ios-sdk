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
}


enum ParseError: Error {
    case json
}


struct Content {
    
    let id: String
//    let fullticket: Bool
//    let fullticketUrl: String?
    var media: Media
    let action: Action?
    let layout: Layout
    
	
	// MARK: - Class Methods
	
	static func contentList(_ json: JSON) throws -> [Content] {
		guard let elements = json["elements"] else { LogWarn("elements array not found"); throw ParseError.json }
		return elements.flatMap(content)
	}
	
	static func content(from json: JSON) -> Content? {
		guard let media = json["layoutView"].flatMap(Media.media) else {
			LogWarn("Content has no layoutView")
			return nil
		}
		
		let content = Content(
			id: json["id"]?.toString() ?? "",
			media: media,
			action: json["action"].flatMap(ActionFactory.action),
			layout: .carousel
		)
		
//		if content.fullticket && content.fullticketUrl == nil { LogWarn("Fullticket has no url"); return nil }
		
		return content
	}

}

func ==(lhs: Content, rhs: Content) -> Bool {
	return lhs.id == rhs.id
}
