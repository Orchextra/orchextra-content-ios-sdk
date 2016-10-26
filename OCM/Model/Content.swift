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
    let media: Media
    
    var elementUrl: String
    
    private let actionInteractor: ActionInteractor
    
    init(slug: String, tags: [String], media: Media, elementUrl: String) {
        self.slug = slug
        self.tags = tags
        self.media  = media
        self.elementUrl = elementUrl
        self.actionInteractor = ActionInteractor(dataManager: ActionDataManager(storage: Storage.shared))
    }
    
    static public func parseContent(from json: JSON) -> Content? {
        
        var tags = [String]()

        if let parsedTags = (json["tags"]?.flatMap { $0.toString() }) {
            tags = parsedTags
        }

        guard let slug = json["slug"]?.toString(),
            let media = json["sectionView"].flatMap(Media.media),
            let elementUrl = json["elementUrl"]?.toString()
        else { return nil }
        
        let content = Content(slug: slug,
                              tags: tags,
                              media: media,
                              elementUrl: elementUrl)
        
        return content
        
    }
    
    // MARK: - PUBLIC
    
    func contains(tag: String) -> Bool {
        return self.tags.filter { $0 == tag }.count > 0
    }
    // MARK: - Factory Methods
    
    
    public func openAction(from viewController: UIViewController) -> UIViewController? {
        guard let action = self.actionInteractor.action(from: self.elementUrl) else { return nil }
        
        
        //        if let view = action.view() {
        //            return view
        //        }
        
        action.run(viewController: viewController)
        return nil
    }
    
}

func == (lhs: Content, rhs: Content) -> Bool {
    return lhs.slug == rhs.slug
}
