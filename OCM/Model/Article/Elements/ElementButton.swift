//
//  ElementButton.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 20/04/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ElementButton: Element {
    
    var element: Element
    var text: String?
    var backgroundImage: Data?
    var action: Action?
    
    init(element: Element, text: String?, backgroundImage: Data?, action: Action?) {
        self.element = element
        self.text = text
        self.backgroundImage = backgroundImage
        self.action = action
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        // TODO: Parse JSON and get all data for creating a button element
        return ElementButton(element: element, text: nil, backgroundImage: nil, action: nil)
    }
    
    func render() -> [UIView] {

        let button = UIButton(frame: CGRect.zero)
        
        // TODO: Setup button with all data
        button.titleLabel?.text = self.text
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(button)
        return elementArray
    }
    
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Button"
    }

}
