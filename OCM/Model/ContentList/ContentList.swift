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
    let  expiredAt: Date?
    let version: String
	
	// MARK: - Factory methods
    
	static func contentList(_ json: JSON) throws -> ContentList {
        
		guard let elements = json["content.elements"] else {
            logWarn("elements array not found"); throw ParseError.json
        }
		
		let contents = elements.flatMap(Content.parseContent)
        
        guard let layoutJson: JSON = json["content.layout"] else {
            logWarn("Layout JSON array not found"); throw ParseError.json
        }
        
        let layoutFactory = LayoutFactory()
        let layout: Layout = layoutFactory.layout(forJSON: layoutJson)
        
        let expiredAt = json["expireAt"]?.toDate()
        
        guard let version = json["version"]?.toString() else {
            logWarn("version not found"); throw ParseError.json
        }
		
        return ContentList(contents: contents, layout: layout, expiredAt: expiredAt, version: version)
	}
}

extension Sequence where Iterator.Element == Content {

    func filter(byTags tags: [String]) -> [Content] {        
        return self.filter { $0.contains(tags: tags) }
    }
}