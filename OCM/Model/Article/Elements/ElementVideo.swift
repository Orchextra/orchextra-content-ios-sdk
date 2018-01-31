//
//  ElementVideo.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


protocol ElementVideoDelegate {
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer)
}

class ElementVideo: Element, ConfigurableElement, ActionableElement {
    
    var customProperties: [String: Any]?

    var delegate: ElementVideoDelegate?
    var element: Element
    var video: Video
    var videoView: VideoView?
    weak var actionableDelegate: ActionableElementDelegate?
    weak var configurableDelegate: ConfigurableElementDelegate?
    
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
            return nil
        }
        
        return ElementVideo(element: element, video: Video(source: source, format: formarValue))
    }

    func render() -> [UIView] {
        var elementArray: [UIView] = self.element.render()
        self.videoView = VideoView(video: self.video, frame: .zero)
        self.videoView?.delegate = self
        if let videoView = self.videoView {
            videoView.addVideoPreview()
            elementArray.append(videoView)
            self.configurableDelegate?.elementRequiresConfiguration(self)
        }
        if let customProperties = self.customProperties {
            let customizableContent = CustomizableContent(identifier: "\(Date().timeIntervalSince1970)_\(video.source)", customProperties: customProperties, viewType: .videoElement)
            OCM.shared.customBehaviourDelegate?.contentNeedsCustomization(customizableContent) { [unowned self] customizableContent in
                customizableContent.customizations.forEach { customization in
                    switch customization {
                    case .disabled:
                        self.videoView?.isEnabled = false
                        self.videoView?.alpha = 0.7
                    case .hidden:
                        self.videoView?.isHidden = true
                    case .viewLayer(let layer):
                        self.videoView?.addSubviewWithAutolayout(layer)
                    case .darkLayer(alpha: let alpha):
                        let layer = UIView()
                        layer.backgroundColor = .black
                        layer.alpha = alpha
                        self.videoView?.addSubviewWithAutolayout(layer)
                    case .lightLayer(alpha: let alpha):
                        let layer = UIView()
                        layer.backgroundColor = .white
                        layer.alpha = alpha
                        self.videoView?.addSubviewWithAutolayout(layer)
                    default:
                        LogWarn("This customization \(customization) hasn't any representation for the video content view.")
                    }
                }
            }
        }
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Video"
    }
    
    // MARK: - Video control methods
    
    func addVideos() {
        self.videoView?.addVideoPlayer()
    }
    
    func play() {
        self.videoView?.play()
    }
    
    func pause() {
        self.videoView?.pause()
    }
    
    func isPlaying() -> Bool {
        return self.videoView?.isPlaying() ?? false
    }
    
    // MARK: - ConfigurableElement
    
    func configure(with info: [AnyHashable: Any]) {
        if let video = info["video"] as? Video {
            self.video = video
            self.videoView?.update(with: video)
        }
    }
    
    func isVisible() -> Bool {
        return self.videoView?.isVideoVisible() ?? false
    }
    
    // MARK: - Constraints
    
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
            withVisualFormat: "V:|[imageView]|",
            options: .alignAllTop,
            metrics: nil,
            views: views))
    }
}

// MARK: - VideoViewDelegate

extension ElementVideo: VideoViewDelegate {
    
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer) {
        self.delegate?.videoPlayerDidExitFromFullScreen(videoPlayer)
    }
    
    func didTapVideo(_ video: Video) {
        self.actionableDelegate?.elementDidTap(self, with: [
            "video": video,
            "player": self.videoView?.videoPlayer
            ]
        )
    }
    
    func videoShouldSound() -> Bool? {
        return self.configurableDelegate?.soundStatusForElement(self)
    }
    
    func enableSound() {
        self.configurableDelegate?.enableSoundForElement(self)
    }
}
