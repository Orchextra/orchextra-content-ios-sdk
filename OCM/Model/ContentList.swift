//
//  ContentList.swift
//  OCM
//
//  Created by Sergio López on 10/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//
import GIGLibrary

struct ContentList {
    let contents: [Content]
    let layout: Layout
	
	// MARK: - Factory methods
	static func contentList(_ json: JSON) throws -> ContentList {
		guard let elements = json["content.elements"] else { LogWarn("elements array not found"); throw ParseError.json }
		
		let contents = elements.flatMap(Content.content)
		let layout: Layout = json["content.layout.type"]?.toString() == "mosaic" ? .mosaic : .carousel
		
		return ContentList(contents: contents, layout: layout)
	}
	
}
