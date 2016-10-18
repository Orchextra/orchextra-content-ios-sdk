//
//  ElementImage.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ElementImage: Element {
    
    var element: Element
    var elementUrl: String
    var imageUrl: String
    
    init(element: Element, elementUrl: String, imageUrl: String) {
        self.element = element
        self.elementUrl = elementUrl
        self.imageUrl = imageUrl
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let elementUrl = json["elementUrl"]?.toString(),
            let imageUrl = json["imageUrl"]?.toString()
            else {
                print("Error parsing")
                return nil}
        
        return ElementImage(element: element, elementUrl: elementUrl, imageUrl: imageUrl)
    }
    
    func render() -> [UIView] {
        let viewVideo = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        viewVideo.backgroundColor = UIColor.green
        var elementArray: [UIView] = self.element.render()
        elementArray.append(viewVideo)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Image"
    }
}
