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
    var htmlText: String
    
    init(element: Element, htmlText: String) {
        self.element = element
        self.htmlText = htmlText
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let htmlText = json["text"]?.toString()
            else {
                logError(NSError(message: ("Error Parsing Rich Text")))
                return nil}
        
        return ElementRichText(element: element, htmlText: htmlText)
    }
    
    func render() -> [UIView] {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .white
        
        let textView = HyperlinkTextView(htmlText: htmlText)
        view.addSubview(textView)
        
        addConstrainst(toLabel: textView, view: view)
        addConstraints(view: view)

        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Rich Text"
    }
    
    func addConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Wconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        view.addConstraints([Wconstraint])
    }
    
    func addConstrainst(toLabel label: UIView, view: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": label])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": label])

        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
}
