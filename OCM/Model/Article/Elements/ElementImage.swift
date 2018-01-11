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
    
    var customProperties: [String: Any]? //!!!

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
        
        let view = UIView(frame: .zero)
        
        let imageView = URLImageView(frame: .zero)
        imageView.url = self.imageUrl
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        view.addSubview(imageView)
        
        imageView.set(autoLayoutOptions: [
            .margin(to: view, top: 20, bottom: 20),
            .centerX(to: view),
            .width(comparingTo: view, relation: .lessThanOrEqual, multiplier: 0.9)
        ])
        
        // Set the original image height and width to show the container
        if let url = URLComponents(string: self.imageUrl),
            let originalwidth = url.queryItems?.first(where: { $0.name == "originalwidth" })?.value,
            let originalheight = url.queryItems?.first(where: { $0.name == "originalheight" })?.value,
            let width = Double(originalwidth),
            let height = Double(originalheight) {
            self.setSizeIfNeeded(to: imageView, size: CGSize(width: width, height: height))
        }
        
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.08)
        
        if Config.thumbnailEnabled, let thumbnail = self.thumbnail {
            imageView.image = UIImage(data: thumbnail) ?? Config.styles.placeholderImage
        } else {
            imageView.image = Config.styles.placeholderImage
        }

        ImageDownloadManager.shared.downloadImage(with: self.imageUrl, completion: { (image, _) in
            if let image = image {
                imageView.image = image
                self.setSizeIfNeeded(to: imageView, size: image.size)
            }
        })
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Image"
    }
    
    // MARK: - Private
    
    private func setSizeIfNeeded(to imageView: UIImageView, size: CGSize) {
        if imageView.heightConstraint() == nil {
            imageView.set(autoLayoutOptions: [
                .aspectRatio(width: size.width, height: size.height)
            ])
        }
    }
}
