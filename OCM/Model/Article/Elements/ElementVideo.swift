//
//  ElementVideo.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ElementVideo: Element {
    
    var element: Element
    var source: String
    var format: String
    var imageUrl: String
    
    init(element: Element, source: String, format: String, imageUrl: String) {
        self.element = element
        self.source = source
        self.format = format
        self.imageUrl = imageUrl
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let source = json["source"]?.toString(),
            let format = json["format"]?.toString(),
            let imageUrl = json["imageUrl"]?.toString()
            else {
                print("Error parsing")
                return nil}
        
        return ElementVideo(element: element, source: source, format: format, imageUrl: imageUrl)
    }
    
    func render() -> [UIView] {
        let viewVideo = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        viewVideo.backgroundColor = UIColor.gray
        var elementArray: [UIView] = self.element.render()
        elementArray.append(viewVideo)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Video"
    }
}
