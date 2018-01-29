//
//  VideoView.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol VideoViewDelegate: class {
    func didTapVideo(_ video: Video)
}

class VideoView: UIView {
    
    // MARK: - Private attributes
    
    var video: Video?
    let reachability = ReachabilityWrapper.shared
    var bannerView: BannerView?
    var isEnabled = true
    weak var delegate: VideoViewDelegate?
    private var videoPreviewImageView: URLImageView?
    
    // MARK: - Initializers
    
    init(video: Video, frame: CGRect) {
        self.video = video
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.video = nil
        super.init(coder: aDecoder)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.red
        addSubview(button)
    }
    
    func addVideoPreview() {
        
        self.videoPreviewImageView = URLImageView(frame: .zero)
        guard let videoPreviewImageView = self.videoPreviewImageView else { logWarn("videoPreviewImageView is nil"); return }
        self.addSubview(videoPreviewImageView)
        self.addConstraints(view: self)
        
        let imagePlayPreview = UIImageView(frame: CGRect.zero)
        imagePlayPreview.translatesAutoresizingMaskIntoConstraints = false
        imagePlayPreview.image = UIImage.OCM.playIconPreviewView
        self.addSubview(imagePlayPreview)
        self.addConstraintsIcon(icon: imagePlayPreview, view: self)
        
        videoPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
        videoPreviewImageView.backgroundColor = UIColor(white: 0, alpha: 0.08)
        videoPreviewImageView.image = Config.styles.placeholderImage
        videoPreviewImageView.contentMode = .scaleAspectFill
        videoPreviewImageView.clipsToBounds = true
        self.addConstraints(imageView: videoPreviewImageView, view: self)
       
        // Add a banner when there isn't internet connection
        if !self.reachability.isReachable() {
            self.bannerView = BannerView()
            self.bannerView?.message = Config.strings.internetConnectionRequired
            if let bannerView = self.bannerView {
                self.addSubview(bannerView, settingAutoLayoutOptions: [
                    .margin(to: self, top: 8, left: 8, right: 8),
                    .height(50)
                    ])
                bannerView.layoutIfNeeded()
                bannerView.setup()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPreview(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func update(with video: Video) {
        self.video = video
        self.loadPreview()
    }
    
    // MARK: Action
    
    @objc func tapPreview(_ sender: UITapGestureRecognizer) {
        guard let video = self.video, self.isEnabled else {  logWarn("video is nil"); return }
        self.delegate?.didTapVideo(video)
    }
    
    // MARK: - Private methods
    
    private func addConstraints(view: UIView) {
        
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
    
    private func addConstraints(imageView: UIImageView, view: UIView) {
        
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
    
    private func addConstraintsIcon(icon: UIImageView, view: UIView) {
        
        let views = ["icon": icon]
        
        view.addConstraint(NSLayoutConstraint.init(item: icon,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint.init(item: icon,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[icon(65)]",
            options: .alignAllCenterY,
            metrics: nil,
            views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[icon(65)]",
            options: .alignAllCenterX,
            metrics: nil,
            views: views))
    }
    
    private func loadPreview() {
        if let previewUrl = self.video?.previewUrl {
            ImageDownloadManager.shared.downloadImage(with: previewUrl, completion: { (image, _) in
                if let image = image {
                    self.videoPreviewImageView?.image = image
                }
            })
        }
    }
}
