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
    let expiredAt: Date?
    var contentVersion: String?
    let numberOfItems: Int?
    
    init(from contentList: ContentList, byAppendingContents newContents: [Content], numberOfItems: Int? = nil) {
        self.init(
            contents: contentList.contents + newContents,
            layout: contentList.layout,
            expiredAt: contentList.expiredAt,
            contentVersion: contentList.contentVersion,
            numberOfItems: numberOfItems
        )
    }
    
    init(contents: [Content], layout: Layout, expiredAt: Date?, contentVersion: String?, numberOfItems: Int? = nil) {
        self.contents = contents
        self.layout = layout
        self.expiredAt = expiredAt
        self.contentVersion = contentVersion
        self.numberOfItems = numberOfItems
    }
    
    // MARK: - Factory methods
    
    static func contentList(_ json: JSON) throws -> ContentList {
        
        guard let elements = json["content.elements"] else {
            LogWarn("elements array not found"); throw ParseError.json
        }
        
        let contents = elements.compactMap(Content.parseContent)
        
        guard let layoutJson: JSON = json["content.layout"] else {
            LogWarn("Layout JSON array not found"); throw ParseError.json
        }
        
        let layout = LayoutFactory.layout(forJSON: layoutJson)
        let expiredAt = json["expireAt"]?.toDate()
        let contentVersion = json["contentVersion"]?.toString()
        
        return ContentList(contents: contents, layout: layout, expiredAt: expiredAt, contentVersion: contentVersion, numberOfItems: json["pagination.totalItems"]?.toInt())
    }
}

extension Sequence where Iterator.Element == Content {
    
    func filter(byTags tags: [String]) -> [Content] {        
        return self.filter { $0.contains(tags: tags) }
    }
}
