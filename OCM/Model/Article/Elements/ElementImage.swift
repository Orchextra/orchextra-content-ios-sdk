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
    var imageUrl: String
    
    init(element: Element, imageUrl: String) {
        self.element = element
        self.imageUrl = imageUrl
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let imageUrl = json["imageUrl"]?.toString()
            else {
                print("Error Parsing Image")
                return nil}
        
        return ElementImage(element: element, imageUrl: imageUrl)
    }
    
    func render() -> [UIView] {
        
        let imageView = UIImageView()
        
        let url = URL(string: self.imageUrl)
        DispatchQueue.global().async {
            if let url = url {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        
                        if let image = image {
                            imageView.image = image
                            imageView.translatesAutoresizingMaskIntoConstraints = false
                            
                            let Hconstraint = NSLayoutConstraint(item: imageView,
                                                                 attribute: NSLayoutAttribute.width,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: imageView,
                                                                 attribute: NSLayoutAttribute.height,
                                                                 multiplier: image.size.width / image.size.height,
                                                                 constant: 0)
                            
                            imageView.addConstraints([Hconstraint])
                        }
                    }
                }
            }
        }
        
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(imageView)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Image"
    }
    
    
}
