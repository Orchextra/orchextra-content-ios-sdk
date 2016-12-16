//
//  ElementHeader.swift
//  OCM
//
//  Created by Judith Medina on 14/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


struct ElementHeader: Element {
    
    var element: Element
    var text: String?
    var imageUrl: String
    var thumbnail: Data?
    
    init(element: Element, text: String?, imageUrl: String, thumbnail: Data?) {
        self.element    = element
        self.text       = text
        self.imageUrl   = imageUrl
        self.thumbnail  = thumbnail
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let imageUrl = json["imageUrl"]?.toString()
            else {
                LogWarn("Error Parsing Header")
                return nil}
        
        let text = json["text"]?.toString()
        
        let thumbnail = json["imageThumb"]?.toString() ?? ""
        let thumbnailData = Data(base64Encoded: thumbnail)
        
        return ElementHeader(element: element, text: text, imageUrl: imageUrl, thumbnail: thumbnailData)
    }
    
    func render() -> [UIView] {
        
        var view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view = self.renderImage(url: self.imageUrl, view: view, thumbnail: self.thumbnail)

//        self.addConstraints(view: view)

        if let richText = text {
            view = self.renderRichText(html: richText, view: view)
        }

        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Header"
    }
    
    //MARK: - PRIVATE 
    
    func renderImage(url: String, view: UIView, thumbnail: Data?) -> UIView {
        
        let imageView = UIImageView()
        let width: Int = Int(UIScreen.main.bounds.width)
        let scaleFactor: Int = Int(UIScreen.main.scale)
        if let thumbnailNotNil = thumbnail {
            let thumbnailImage = UIImage(data:thumbnailNotNil)
            imageView.image = thumbnailImage
        }
        view.addSubview(imageView)
        view.clipsToBounds = true
        
        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: self.imageUrl,
            width: width,
            height:nil,
            scaleFactor: scaleFactor
        )

        let urlAddptedToSize = urlSizeComposserWrapper.urlCompossed
        let url = URL(string: urlAddptedToSize)
        DispatchQueue.global().async {
            if let url = url {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        if let image = image {
                            imageView.image = image
                            imageView.translatesAutoresizingMaskIntoConstraints = false
                            self.addConstraints(view: view, image: image)
                            self.addConstraints(imageView: imageView, view: view)
                        }
                    }
                }
            }
        }

        return view
    }
    
    func renderRichText(html: String, view: UIView) -> UIView {
        
        let label = UILabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.html = html
        label.textAlignment = .center
        view.addSubview(label)
        addConstrainst(toLabel: label, view: view)

        return view
    }
    
    // MARK: - PRIVATE
    
    func addConstraints(imageView: UIImageView, view: UIView) {
        
        let views = ["imageView": imageView]
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[imageView]|",
            options: .alignAllTop,
            metrics: nil,
            views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[imageView]|",
            options: .alignAllTop,
            metrics: nil,
            views: views))
    }
    
    func addConstrainst(toLabel label: UILabel, view: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[label]-|",
            options: [],
            metrics: nil,
            views: ["label": label])
        
        let verticalConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-10-[label]-10-|",
            options: [],
            metrics: nil,
            views: ["label": label])
        
        view.addConstraints(horizontalConstrains)
        view.addConstraints(verticalConstrains)
    }
    
    func addConstraints(view: UIView, image: UIImage) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let Hconstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.height,
            multiplier: image.size.width / image.size.height,
            constant: 0)
        
        view.addConstraints([Hconstraint])
    }
    
}
