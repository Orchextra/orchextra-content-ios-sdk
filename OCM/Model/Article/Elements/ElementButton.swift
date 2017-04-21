//
//  ElementButton.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 20/04/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

enum ElementButtonType: String {
    case small
    case medium
    case large
}

struct ElementButton: Element {
    
    var element: Element
    var buttonType: ElementButtonType
    var elementURL: String

    var title: String?
    var titleColor: UIColor?
    var backgroundColor: UIColor?
    
    var backgroundImageURL: String?

    init(element: Element, buttonType: ElementButtonType, elementURL: String, title: String?, titleColor: UIColor?, backgroundColor: UIColor?) {
        
        self.element = element
        self.buttonType = buttonType
        self.elementURL = elementURL
        self.title = title
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
    
    init(element: Element, buttonType: ElementButtonType, elementURL: String, backgroundImageURL: String?) {
        
        self.element = element
        self.buttonType = buttonType
        self.elementURL = elementURL
        self.backgroundImageURL = backgroundImageURL
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        // TODO: Parse JSON and get all data for creating a button element
        guard let elementURL = json["elementUrl"]?.toString(),
            let buttonTypeLiteral = json["type"]?.toString(),
            let buttonType = ElementButtonType(rawValue: buttonTypeLiteral) else {
                logWarn("Error Parsing Button")
                return nil}
        
        if let title = json["text"]?.toString(),
            let titleColor = UIColor(fromHexString: json["textColor"]?.toString()),
            let backgroundColor = UIColor(fromHexString: json["bgColor"]?.toString()) {
            return ElementButton(element: element, buttonType: buttonType, elementURL: elementURL, title: title, titleColor: titleColor, backgroundColor: backgroundColor)
        } else if let backgroundImageURL = json["imageUrl"]?.toString() {
            return ElementButton(element: element, buttonType: buttonType, elementURL: elementURL, backgroundImageURL: backgroundImageURL)
        }
        return .none
    }
    
    func render() -> [UIView] {

        let button = UIButton(frame: CGRect.zero)
        
        // TODO: Setup button with all data
        button.titleLabel?.text = self.title
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(button)
        return elementArray
    }
    
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Button"
    }

}
