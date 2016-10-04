//
//  Widget.swift
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


class Widget {
    
    let id: String
    let fullticket: Bool
    let fullticketUrl: String?
    var media: Media
    let action: Action?
    let layout: Layout
    
	
	// MARK: - Class Methods
	
	class func widgetList(_ json: JSON) throws -> [Widget] {
		return try json.map { try Widget(json: $0) }
	}
	
	
    // MARK: - Initializers
    
    init(id: String, fullticket: Bool, media: Media, layout: Layout, fullticketUrl: String? = nil, action: Action? = nil) {
        self.id = id
        self.fullticket = fullticket
        self.media = media
        self.layout = layout
        self.fullticketUrl = fullticketUrl
        self.action = action
    }
    
    convenience init(json: JSON) throws {
        guard
            let id = json["id"]?.toString(),
            let jsonMedia = json["media"],
            let media = try? Media(json: jsonMedia)
            else { throw ParseError.json }
        
        self.init(
            id: id,
            fullticket: json["fullticket"]?.toBool() ?? false,
            media: media,
            layout: .carousel,
            fullticketUrl: json["media_url_fullTicket"]?.toString(),
            action: ActionFactory.action(json["actions.data"]?[0])
        )
        
        if self.fullticket && self.fullticketUrl == nil { throw ParseError.json }
    }
}

func ==(lhs: Widget, rhs: Widget) -> Bool {
	return lhs.id == rhs.id
}
