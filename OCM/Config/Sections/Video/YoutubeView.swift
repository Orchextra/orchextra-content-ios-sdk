//
//  YoutubeView.swift
//  OCM
//
//  Created by Judith Medina on 16/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class YoutubeView: UIView {

    let videoID: String
    let previewUrl: String
    let reachability = ReachabilityWrapper.shared
    var bannerView: BannerView?
    
    init(with videoID: String, frame: CGRect) {
        self.videoID = videoID
        self.previewUrl = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.videoID = ""
        self.previewUrl = ""
        super.init(coder: aDecoder)

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.red
        addSubview(button)
    }
    
    func addPreviewYoutube() {
        
        let videoPreviewImageView = URLImageView(frame: .zero)
        self.addSubview(videoPreviewImageView)
        self.addConstraints(view: self)
        
        let imagePlayPreview = UIImageView(frame: CGRect.zero)
        imagePlayPreview.translatesAutoresizingMaskIntoConstraints = false
        imagePlayPreview.image = UIImage.OCM.playIconPreviewView
        self.addSubview(imagePlayPreview)
        self.addConstraintsIcon(icon: imagePlayPreview, view: self)

        ImageDownloadManager.shared.downloadImage(with: self.previewUrl, completion: { (image, cached, _) in
            if let image = image {
                videoPreviewImageView.image = image
                videoPreviewImageView.translatesAutoresizingMaskIntoConstraints = false
                videoPreviewImageView.cached = cached
                videoPreviewImageView.contentMode = .scaleAspectFill
                videoPreviewImageView.clipsToBounds = true
                self.addConstraints(imageView: videoPreviewImageView, view: self)
            }
        })
        
        // Add a banner when there isn't internet connection
        if !self.reachability.isReachable() {
            self.bannerView = BannerView()
            self.bannerView?.message = Config.strings.internetConnectionRequired
            if let bannerView = self.bannerView {
                self.addSubview(bannerView, settingAutoLayoutOptions: [
                    .margin(to: self, top: 58, left: 8, right: 8),
                    .height(50)
                ])
                bannerView.layoutIfNeeded()
                bannerView.setup()
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPreview(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Action
    
    func tapPreview(_ sender: UITapGestureRecognizer) {
        guard
            self.reachability.isReachable(),
            let viewController = OCM.shared.wireframe.showYoutubeVC(videoId: self.videoID)
        else {
            return
        }
        OCM.shared.wireframe.show(viewController: viewController)
        OCM.shared.analytics?.track(with: [
            AnalyticConstants.kContentType: AnalyticConstants.kVideo,
            AnalyticConstants.kValue: self.videoID
        ])
    }
	
	
    // MARK: - Constraints
    
    func addConstraints(view: UIView) {
        
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
    
    func addConstraintsIcon(icon: UIImageView, view: UIView) {
        
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
    
}
