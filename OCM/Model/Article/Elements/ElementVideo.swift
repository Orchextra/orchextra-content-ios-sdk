//
//  ElementVideo.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ElementVideo: Element {
    
    var element: Element
    var video: Video
    var videoView: VideoView?
    
    init(element: Element, video: Video) {
        self.element = element
        self.video = video
    }
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let source = json[ParsingConstants.VideoElement.kSource]?.toString(),
            let format = json[ParsingConstants.VideoElement.kFormat]?.toString(),
            let formarValue = VideoFormat.from(format)
            else {
                logError(NSError(message: ("Error Parsing Article: Video")))
                return nil}
        
        return ElementVideo(element: element, video: Video(source: source, format: formarValue))
    }

    func render() -> [UIView] {
        
        let videoView = VideoView(video: self.video, videoInteractor: VideoInteractor(), frame: .zero)
        videoView.addVideoPreview()
        self.videoView = videoView

        var elementArray: [UIView] = self.element.render()
        elementArray.append(videoView)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Video"
    }
    
    // MARK: - 
    
    func addConstraints(view: UIView) {
        
        let view = UIView(frame: CGRect.zero)

        view.translatesAutoresizingMaskIntoConstraints = false
        let widthPreview = UIScreen.main.bounds.width
        let heightPreview = (widthPreview * 9) / 16
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
