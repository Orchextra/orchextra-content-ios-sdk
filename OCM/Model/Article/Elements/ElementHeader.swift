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
        
        guard let imageUrl = json[ParsingConstants.HeaderElement.kImageURL]?.toString()
            else {
                logWarn("Error Parsing Header")
                return nil}
        
        let text = json[ParsingConstants.HeaderElement.kText]?.toString()
        
        let thumbnail = json[ParsingConstants.HeaderElement.kImageThumbnail]?.toString() ?? ""
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
    
    // MARK: - PRIVATE 
    
    func renderImage(url: String, view: UIView, thumbnail: Data?) -> UIView {
        
        let imageView = URLImageView(frame: .zero)
        imageView.url = self.imageUrl
        view.addSubview(imageView)
        
        // Set the original image height and width to show the container
        if let url = URLComponents(string: self.imageUrl),
            let originalwidth = url.queryItems?.first(where: { $0.name == "originalwidth" })?.value,
            let originalheight = url.queryItems?.first(where: { $0.name == "originalheight" })?.value,
            let width = Double(originalwidth),
            let height = Double(originalheight) {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints(view: view, imageSize: CGSize(width: width, height: height))
            self.addConstraints(imageView: imageView, view: view)
        }
        
        view.clipsToBounds = true
        
        ImageDownloadManager.shared.downloadImage(with: self.imageUrl, completion: { (image, _) in
            if let image = image {
                imageView.image = image
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.removeConstraints(view.constraints)
                self.addConstraints(view: view, imageSize: image.size)
                self.addConstraints(imageView: imageView, view: view)
            }
        })

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
    
    func addConstraints(view: UIView, imageSize: CGSize) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let Hconstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.height,
            multiplier: imageSize.width / imageSize.height,
            constant: 0)
        
        view.addConstraints([Hconstraint])
    }
    
}
