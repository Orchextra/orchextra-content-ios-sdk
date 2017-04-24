//
//  Element.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

protocol ActionableElementDelegate: class {
    func performAction(of element: Element, with info: String)
}

protocol ActionableElement {
    weak var delegate: ActionableElementDelegate? { get set }
}

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
        
        guard let type = json[ParsingConstants.Element.kType]?.toString(),
            let render = json[ParsingConstants.Element.kRender]
            else {return nil}
        
        switch type {
        case ParsingConstants.VideoElement.kVideoType:
            return ElementVideo.parseRender(from: render, element: element)
        case ParsingConstants.ImageElement.kImageType:
            return ElementImage.parseRender(from: render, element: element)
        case ParsingConstants.RichTextElement.kRichTextType:
            return ElementRichText.parseRender(from: render, element: element)
        case ParsingConstants.HeaderElement.kHeaderType:
            return ElementHeader.parseRender(from: render, element: element)
        case ParsingConstants.ButtonElement.kButtonType:
            return ElementButton.parseRender(from: render, element: element)
        default:
            return nil
        }
    }
}
