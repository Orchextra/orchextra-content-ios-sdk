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
    
    init(with videoID: String, frame: CGRect) {
        self.videoID = videoID
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.videoID = ""

        super.init(coder: aDecoder)

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.red
        addSubview(button)
    }
    
    func addPreviewYoutube() {
        
        let previewURL = "https://img.youtube.com/vi/\(self.videoID)/hqdefault.jpg"
        let imageVideoPreview = UIImageView(frame:  CGRect.zero)
        self.addSubview(imageVideoPreview)
        
        let imagePlayPreview = UIImageView(frame: CGRect.zero)
        imagePlayPreview.translatesAutoresizingMaskIntoConstraints = false
        imagePlayPreview.image = UIImage.OCM.playIconPreviewView
        self.addSubview(imagePlayPreview)
        self.addConstraintsIcon(icon: imagePlayPreview, view: self)

        let url = URL(string: previewURL)
        DispatchQueue.global().async {
            if let url = url {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        
                        if let image = image {
                            imageVideoPreview.image = image
                            imageVideoPreview.translatesAutoresizingMaskIntoConstraints = false
                            self.addConstraints(imageView: imageVideoPreview, view: self)
                            self.addConstraints(view: self)
                        }
                    }
                }
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapPreview(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Action
    
    func tapPreview(_ sender: UITapGestureRecognizer) {
        
        guard let viewController = OCM.shared.wireframe.showYoutubeVC(videoId: self.videoID) else { return }
        OCM.shared.wireframe.show(viewController: viewController)
    }
	
	
    // MARK: - Constraints
    
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
