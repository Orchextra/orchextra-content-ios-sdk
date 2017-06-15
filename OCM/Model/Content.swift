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

public struct Content {
    
    let slug: String
    let tags: [String]
    let name: String?
    let media: Media
    let requiredAuth: String
    var type: String? {
        return Content.contentType(of: self.elementUrl)
    }
    
    var elementUrl: String
    private let actionInteractor: ActionInteractor
    
    init(slug: String, tags: [String], name: String?, media: Media, elementUrl: String, requiredAuth: String) {
        self.slug = slug
        self.tags = tags
        self.name = name
        self.media  = media
        self.requiredAuth = requiredAuth
        self.elementUrl = elementUrl
        self.actionInteractor = ActionInteractor(
            contentDataManager: .defaultDataManager()
        )
    }
    
    static public func parseContent(from json: JSON) -> Content? {
        
        var tags = [String]()
        
        if let parsedTags = (json["tags"]?.flatMap { $0.toString() }) {
            tags = parsedTags
        }
        
        guard let slug = json["slug"]?.toString(),
            let media = json["sectionView"].flatMap(Media.media),
            let requiredAuth = json["segmentation.requiredAuth"]?.toString(),
            let elementUrl = json["elementUrl"]?.toString()
            else { return nil }
        
        let name = json["name"]?.toString()
        let content = Content(slug: slug,
                              tags: tags,
                              name: name,
                              media: media,
                              elementUrl: elementUrl,
                              requiredAuth: requiredAuth)
        
        return content
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

    // MARK: - Factory Methods

    public func openAction(from viewController: UIViewController) {
        self.actionInteractor.action(with: self.elementUrl) { action, _ in
            action?.run(viewController: viewController)
        }
    }
}

func == (lhs: Content, rhs: Content) -> Bool {
    return lhs.slug == rhs.slug
}
