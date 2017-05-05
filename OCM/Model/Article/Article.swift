//
//  Article.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import GIGLibrary

struct Article {
    let slug: String
    var preview: Preview?
    var elements: [Element]
    
    init(slug: String, preview: Preview?, elements: [Element]) {
        self.slug = slug
        self.preview = preview
        self.elements = elements
    }
    
    static func article(from json: JSON, preview: Preview?) -> Article? {
        guard let slug = json["slug"]?.toString() else { return nil }
        var articleElements: Element = ArticleElement()
        var elems: [Element] = []
        if let elements = json["render.elements"] {
            for jsonElement in elements {
                if let element = ElementFactory.element(from: jsonElement, element: articleElements) {
                    articleElements = element
                    elems.append(articleElements)
                }
            }
        }
        return Article(slug: slug, preview: preview, elements: elems)
    }
}
