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
        imageView.imageFromURL(urlString: self.imageUrl)

        var view = UIView(frame: UIScreen.main.bounds)
        view.addSubviewWithAutolayout(imageView)
        view = addConstraints(view: view)
        

        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Image"
    }
    
    
    func addConstraints(view: UIView) -> UIView {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Hconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        view.addConstraints([Hconstraint])
        return view
    }
    
}
