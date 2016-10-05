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
    let fullticket: Bool
    let fullticketUrl: String?
    var media: Media
    let action: Action?
    let layout: Layout
    
	
	// MARK: - Class Methods
	
	static func contentList(_ json: JSON) throws -> [Content] {
		return try json.map(self.content)
	}
	
	static func content(from json: JSON) throws -> Content {
		guard
			let id = json["id"]?.toString(),
			let jsonMedia = json["media"],
			let media = try? Media(json: jsonMedia)
			else { throw ParseError.json }
		
		let content = Content(
			id: id,
			fullticket: json["fullticket"]?.toBool() ?? false,
			fullticketUrl: json["media_url_fullTicket"]?.toString(),
			media: media,
			action: json["actions.data"]?[0].flatMap(ActionFactory.action),
			layout: .carousel
		)
		
		if content.fullticket && content.fullticketUrl == nil { throw ParseError.json }
		
		return content
	}

}

func ==(lhs: Content, rhs: Content) -> Bool {
	return lhs.id == rhs.id
}
