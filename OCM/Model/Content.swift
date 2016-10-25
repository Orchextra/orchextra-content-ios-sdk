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
    let media: Media
    var elementUrl: String
	
    private let actionInteractor: ActionInteractor

    init(slug: String, media: Media, elementUrl: String) {
        self.slug = slug
        self.media  = media
        self.elementUrl = elementUrl
        self.actionInteractor = ActionInteractor(dataManager: ActionDataManager(storage: Storage.shared))
    }
    
    static public func parseContent(from json: JSON) -> Content? {
        
        guard let slug  = json["slug"]?.toString(),
            let media   = json["sectionView"].flatMap(Media.media),
            let elementUrl  = json["elementUrl"]?.toString()
            else { return nil }
        
        let content = Content(slug: slug,
                              media: media,
                              elementUrl: elementUrl)
                
        return content
        
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
