//
//  ParsingConstants.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 24/04/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct ParsingConstants {
    
    struct Element {
        static let kType = "type"
        static let kRender = "render"
        static let customProperties = "customProperties"
    }
    
    struct ImageElement {
        static let kImageType = "image"
        static let kImageURL = "imageUrl"
        static let kImageThumbnail = "imageThumb"
    }
    
    struct RichTextElement {
        static let kRichTextType = "richText"
        static let kText = "text"
    }
    
    struct VideoElement {
        static let kVideoType = "video"
        static let kSource = "source"
        static let kFormat = "format"
    }
    
    struct HeaderElement {
        static let kHeaderType = "header"
        static let kImageURL = "imageUrl"
        static let kText = "text"
        static let kImageThumbnail = "imageThumb"
    }
    
    struct ButtonElement {
        static let kButtonType = "button"
        static let kType = "type"
        static let kSize = "size"
        static let kElementURL = "elementUrl"
        static let kText = "text"
        static let kTextColor = "textColor"
        static let kBackgroundColor = "bgColor"
        static let kBackgroundImageURL = "imageUrl"
    }
}
