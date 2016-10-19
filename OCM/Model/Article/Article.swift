//
//  Article.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct Article {

    let slug: String
    var preview: Preview?
    var elements: [UIView]?
    
    init(slug: String, preview: Preview?) {
        
        self.slug = slug
        self.preview = preview
    }
    
    static func parseArticle(from json: JSON) -> Article? {
        guard
        let slug = json["slug"]?.toString()
            else {return nil}
        
        var previewParsed: Preview?
        if let previewJson = json["preview"] {
            previewParsed = Preview.parsePreview(json: previewJson)
        }
        
        var articleElements: Element = ArticleElement()

        if let elements = json["render.elements"] {
            
            for jsonElement in elements {
                
                if let element = ElementFactory.element(from: jsonElement, element: articleElements) {
                    articleElements = element
                }
            }
 
            print(articleElements.descriptionElement())
        }
        
        return Article(slug: slug, preview: previewParsed)
    }
}
