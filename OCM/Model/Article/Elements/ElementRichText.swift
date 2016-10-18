//
//  ElementRichText.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ElementRichText: Element {
    
    var element: Element
    var html: String
    
    init(element: Element, html: String) {
        self.element = element
        self.html = html
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let html = json["html"]?.toString()
            else {
                print("Error parsing")
                return nil}
        
        return ElementRichText(element: element, html: html)
    }
    
    func render() -> [UIView] {
        let viewVideo = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        viewVideo.backgroundColor = UIColor.orange
        var elementArray: [UIView] = self.element.render()
        elementArray.append(viewVideo)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Rich Text"
    }
}
