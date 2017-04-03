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
        
        guard let imageUrl = json["imageUrl"]?.toString()
            else {
                logError(NSError(message: (("Error Parsing Image"))))
                return nil}
        
        let thumbnail = json["imageThumb"]?.toString() ?? ""
        let thumbnailData = Data(base64Encoded: thumbnail)
        
        return ElementImage(element: element, imageUrl: imageUrl, thumbnail: thumbnailData)
    }
    
    func render() -> [UIView] {
        let view = UIView(frame: CGRect.zero)
        let width: Int = Int(UIScreen.main.bounds.width)
        let scaleFactor: Int = Int(UIScreen.main.scale)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        
        if let thumbnailNotNil = thumbnail {
            let thumbnailImage = UIImage(data:thumbnailNotNil)
            imageView.image = thumbnailImage
        }
        
        view.addSubview(imageView)
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
