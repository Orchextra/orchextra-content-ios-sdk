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
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        var view = UIView(frame: frame)
        view.backgroundColor = UIColor.red
        
        var frameLabel = frame
        frameLabel.size.height = 40
        let label = UILabel(frame: frameLabel)
        label.text = "RICH TEXT"
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
        return  self.element.descriptionElement() + "\n Rich Text"
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
