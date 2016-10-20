//
//  Element.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

protocol Element {
    
    func render() -> [UIView]
    func descriptionElement() -> String
}

// IMPLEMENTATION BY DEFAULT
extension Element {
    func render() -> [UIView] {
        return []
    }
}


class ElementFactory {
    
    class func element(from json: JSON, element: Element) -> Element? {
        
        guard let type = json["type"]?.toString(),
            let render = json["render"]
            else {return nil}
        
        switch type {
        case "video":
            print("video")
            return ElementVideo.parseRender(from: render, element: element)
        case "image":
            return ElementImage.parseRender(from: render, element: element)
        case "richText":
            return ElementRichText.parseRender(from: render, element: element)
        default:
            return nil
        }
    }
}
