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
        
        /*guard let html = json["html"]?.toString()
            else {
                print("Error Parsing Rich Text")
                return nil}
        */
        
        let html = "<html><style>body{ color: rgb(71,71,71);} </style><b style=\"font-size: 29;\">FESTIVAL IPSUM DOLOR SIT CONSECTETUR</b><br><br> <p style=\"font-size: 16\"> Consectetur adipiscing elit. Nullam in congue mi, et dignissim tortor. Etiam quis mauris quis erat sollicitudin iaculis. Curabitur ac condimentum lectus. Donec tempor interdum eros, quis dictum velit gravida eget. Nullam suscipit arcu at tortor vehicula dignissim. Fusce viverra eros tortor, ac rutrum magna convallis vel. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Quisque et leo interdum, consectetur neque ut, lacinia neque. Nam varius tellus eget purus sodales, at lobortis nisl malesuada. Vivamus ac vehicula leo, sit amet fringilla nunc. Pellentesque eget varius nulla. Fusce facilisis nisl non lorem porta, eget euismod dui ullamcorper. Morbi gravida mattis risus, ut ullamcorper tellus commodo sit amet. Vivamus fermentum hendrerit ex.Quisque vestibulum varius elit vitae luctus. Fusce ac ornare dolor, et mattis arcu. Curabitur dignissim venenatis eleifend. Praesent rhoncus enim ac arcu cursus placerat. Vestibulum tempor tempus commodo. Nulla ac diam convallis, vulputate dui at, efficitur sapien. Donec in velit erat. Nunc vitae justo at magna convallis blandit. Sed gravida, metus sit amet pharetra tincidunt, lorem turpis maximus justo, ac imperdiet nibh turpis et eros. Ut rutrum efficitur leo vehicula porta. </p></html>"
        
        return ElementRichText(element: element, html: html)
    }
    
    func render() -> [UIView] {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.html = html
        view.addSubview(label)
        
        addConstrainst(toLabel: label, view: view)
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
        
        let Hconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        view.addConstraints([Hconstraint])
    }
    
    func addConstrainst(toLabel label: UILabel, view: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": label])
        let verticalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": label])

        view.addConstraints(horizontalConstrains)
        view.addConstraints(verticalConstrains)
    }
}
