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
    var youtubeView: YoutubeView
    
    let view = UIView(frame: CGRect.zero)

    init(element: Element, source: String, format: String, imageUrl: String) {
        self.element = element
        self.source = source
        self.format = format
        self.imageUrl = imageUrl
        self.youtubeView = YoutubeView(with: source, frame: CGRect.zero)

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
        
        self.youtubeView.addPreviewYoutube()
//        
//        let previewURL = "https://img.youtube.com/vi/\(self.source)/hqdefault.jpg"
//        let imageVideoPreview = UIImageView(frame:  CGRect.zero)
//        view.addSubview(imageVideoPreview)
//
//        let url = URL(string: previewURL)
//        DispatchQueue.global().async {
//            if let url = url {
//                let data = try? Data(contentsOf: url)
//                DispatchQueue.main.async {
//                    if let data = data {
//                        let image = UIImage(data: data)
//                        
//                        if let image = image {
//                            imageVideoPreview.image = image
//                            imageVideoPreview.translatesAutoresizingMaskIntoConstraints = false
//                            self.addConstraints(imageView: imageVideoPreview, view: self.view)
//                            self.addConstraints(view: self.view)
//
//                        }
//                    }
//                }
//            }
//        }
//        imageVideoPreview.imageFromURL(urlString: previewURL, placeholder:  Config.placeholder)
//        
//        let tapGesture = UITapGestureRecognizer(target: ElementVideo.self, action: Selector(("tapPreview:")))
//        self.view.addGestureRecognizer(tapGesture)
//        
        
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(self.youtubeView)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Video"
    }
    
    // MARK: - 
    
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
    
    
    // MARK: Action
    
    func tapPreview(_ sender: UITapGestureRecognizer) {
        print("Video tapped")
    }
    
}
