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
        guard let imageUrl = json[ParsingConstants.HeaderElement.kImageURL]?.toString() else {
            logWarn("Error Parsing Header")
            return nil
        }
        
        let text = json[ParsingConstants.HeaderElement.kText]?.toString()
        let thumbnail = json[ParsingConstants.HeaderElement.kImageThumbnail]?.toString() ?? ""
        let thumbnailData = Data(base64Encoded: thumbnail)
        
        return ElementHeader(element: element, text: text, imageUrl: imageUrl, thumbnail: thumbnailData)
    }
    
    func render() -> [UIView] {
        
        let headerView = UIView(frame: CGRect.zero)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.render(with: self.imageUrl, thumbnail: self.thumbnail, title: self.text ?? "", in: headerView)

        var elementArray: [UIView] = self.element.render()
        elementArray.append(headerView)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Header"
    }
    
    // MARK: - Private helpers
    
    private func render(with imageUrl: String, thumbnail: Data?, title: String, in view: UIView) {
        
        view.clipsToBounds = true

        // Create UIImageView and add to view hierarchy
        let imageView = URLImageView(frame: .zero)
        imageView.url = self.imageUrl
        view.addSubview(imageView)
        
        // Create UILabel and add to view hierarchy
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.html = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Gotham-Medium", size: 28)
        titleLabel.textColor = UIColor(fromRed: 71, green: 71, blue: 71)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        let attributedString = NSMutableAttributedString(string: title.uppercased())
        attributedString.addAttribute(NSAttributedStringKey.kern, value: CGFloat(3.0), range: NSRange(location: 0, length: attributedString.length))
        titleLabel.attributedText = attributedString
        view.addSubview(titleLabel)

        // Set header size according to original image size
        if let url = URLComponents(string: self.imageUrl),
            let originalWidth = url.queryItems?.first(where: { $0.name == "originalwidth" })?.value,
            let originalHeight = url.queryItems?.first(where: { $0.name == "originalheight" })?.value,
            let width = Double(originalWidth),
            let height = Double(originalHeight) {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let headerSize = CGSize(width: width, height: height)
            self.addConstraints(headerImageView: imageView, headerTitleLabel: titleLabel, containerView: view)
            self.addSizeConstraints(view: imageView, size: headerSize)
            self.addHeightConstraint(label: titleLabel)
        }
        
        ImageDownloadManager.shared.downloadImage(with: self.imageUrl, completion: { (image, _) in
            if let image = image {
                imageView.image = image
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.removeConstraints(view.constraints)
                self.addConstraints(headerImageView: imageView, headerTitleLabel: titleLabel, containerView: view)
                self.addSizeConstraints(view: imageView, size: image.size)
                self.addHeightConstraint(label: titleLabel)
            }
        })
    }
    
    private func addConstraints(headerImageView: UIImageView, headerTitleLabel: UILabel, containerView: UIView) {
        
        containerView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[imageView]|",
            options: .alignAllTop,
            metrics: nil,
            views: ["imageView": headerImageView]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-10-[label]-10-|",
            options: .alignAllTop,
            metrics: nil,
            views: ["label": headerTitleLabel]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[imageView]-[label]-|",
            metrics: nil,
            views: ["imageView": headerImageView,
                    "label": headerTitleLabel]))
    }
    
    private func addSizeConstraints(view: UIView, size: CGSize) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let Hconstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.height,
            multiplier: size.width / size.height,
            constant: 0)
        view.addConstraints([Hconstraint])
    }
    
    private func addHeightConstraint(label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        let Hconstraint = NSLayoutConstraint(item: label,
                                             attribute: NSLayoutAttribute.height,
                                             relatedBy: NSLayoutRelation.greaterThanOrEqual,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: 0)
        label.addConstraints([Hconstraint])
    }
    
}
