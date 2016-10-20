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
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        var view = UIView(frame: frame)
        view.backgroundColor = UIColor.green
        
        var frameLabel = frame
        frameLabel.size.height = 40
        let label = UILabel(frame: frameLabel)
        label.text = "VIDEO"
        label.textColor = UIColor.black
        label.center = view.center
        label.textAlignment = .center
        view.addSubview(label)
        
        view = addConstraints(view: view)
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Video"
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
        
        let Vconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.height,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: view.frame.height)
        
        view.addConstraints([Hconstraint, Vconstraint])
        return view
    }
}
