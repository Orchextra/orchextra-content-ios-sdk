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
    var thumbnail: Data?
    
    init(element: Element, imageUrl: String, thumbnail: Data?) {
        self.element = element
        self.imageUrl = imageUrl
        self.thumbnail = thumbnail
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let imageUrl = json[ParsingConstants.ImageElement.kImageURL]?.toString()
            else {
                logError(NSError(message: (("Error Parsing Image"))))
                return nil}
        
        let thumbnail = json[ParsingConstants.ImageElement.kImageThumbnail]?.toString() ?? ""
        let thumbnailData = Data(base64Encoded: thumbnail)
        
        return ElementImage(element: element, imageUrl: imageUrl, thumbnail: thumbnailData)
    }
    
    func render() -> [UIView] {
        let view = UIView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        
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
        
        ImageDownloadManager.shared.downloadImage(with: self.imageUrl, completion: { (image, _) in
            if let image = image {
                imageView.image = image
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.removeConstraints(view.constraints)
                self.addConstraints(view: view, imageSize: image.size)
                self.addConstraints(imageView: imageView, view: view)
            }
        })
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Image"
    }
    
    // MARK: - PRIVATE
    
    func addConstraints(imageView: UIImageView, view: UIView) {
        
        let views = ["imageView": imageView]
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[imageView]-|",
            options: .alignAllTop,
            metrics: nil,
            views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[imageView]-|",
            options: .alignAllTop,
            metrics: nil,
            views: views))
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
