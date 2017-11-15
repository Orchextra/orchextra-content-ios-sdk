//
//  Content.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


enum LayoutType {
    case carousel
    case mosaic
}

enum ParseError: Error {
    case json
}

public struct Content {
    
    let slug: String
    let tags: [String]
    let name: String?
    let media: Media
    let requiredAuth: String
    private let jsonValue: JSON? // We store the json value to avoid a transformation to JSON from the model
    var type: String? {
        return Content.contentType(of: self.elementUrl)
    }
    
    var elementUrl: String
    
    init(slug: String, tags: [String], name: String?, media: Media, elementUrl: String, requiredAuth: String, jsonValue: JSON? = nil) {
        self.slug = slug
        self.tags = tags
        self.name = name
        self.media  = media
        self.requiredAuth = requiredAuth
        self.elementUrl = elementUrl
        self.jsonValue = jsonValue
    }
    
    static public func parseContent(from json: JSON) -> Content? {
        
        var tags = [String]()
        
        if let parsedTags = (json["tags"]?.flatMap { $0.toString() }) {
            tags = parsedTags
        }
        
        guard
            let slug = json["slug"]?.toString(),
            let media = json["sectionView"].flatMap(Media.media),
            let requiredAuth = json["segmentation.requiredAuth"]?.toString(),
            let elementUrl = json["elementUrl"]?.toString()
        else {
            logWarn("The content parsed from json is nil")
            return nil
        }
        
        let name = json["name"]?.toString()
        let content = Content(slug: slug,
                              tags: tags,
                              name: name,
                              media: media,
                              elementUrl: elementUrl,
                              requiredAuth: requiredAuth,
                              jsonValue: json)
        
        return content
    }
    
    func toJSON() -> JSON? {
        return self.jsonValue
    }
    
    static func contentType(of elementUrl: String) -> String? {
        return elementUrl.matchingStrings(regex: "/element/([a-zA-Z]+)/?").first?[1]
    }
    
    // MARK: - PUBLIC
    
    func contains(tags tagsToMatch: [String]) -> Bool {
        let tags = Set(self.tags)
        let tagsToMatch = Set(tagsToMatch)
        
        return tags.isStrictSuperset(of: tagsToMatch)
    }
}

extension Content: Hashable {
    
    public var hashValue: Int {
        return self.slug.hashValue
    }
    
    public static func == (lhs: Content, rhs: Content) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
