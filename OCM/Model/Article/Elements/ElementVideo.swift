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
                print("Error Parsing Article: Video")
                return nil}
        
        return ElementVideo(element: element, source: source, format: format, imageUrl: imageUrl)
    }

    func render() -> [UIView] {
        
        let previewURL = "https://img.youtube.com/vi/\(self.source)/hqdefault.jpg"
        let imageVideoPreview = UIImageView(frame:  CGRect.zero)
        imageVideoPreview.imageFromURL(urlString: previewURL, placeholder:  Config.placeholder)
        
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.gray
        addConstraints(view: imageVideoPreview)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector(("tapPreview:")))
        imageVideoPreview.addGestureRecognizer(tapGesture)
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Video"
    }
    
    func addConstraints(view: UIView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let widthPreview = UIScreen.main.bounds.width
        let heightPreview = (widthPreview*9)/16
        let Hconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: widthPreview)
        
        let Vconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.height,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: heightPreview)
        
        view.addConstraints([Hconstraint, Vconstraint])
    }
    
    // MARK: Action
    
    func tapPreview(_ sender: UITapGestureRecognizer) {
        print("Video tapped")
    }
    
}
