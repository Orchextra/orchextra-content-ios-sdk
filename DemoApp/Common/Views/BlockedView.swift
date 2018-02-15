//
//  BlockedView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 15/02/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class BlockedView {
    
    class func instantiate() -> UIView {
        let blockedView = UIView(frame: CGRect.zero)
        blockedView.addSubviewWithAutolayout(UIImageView(image: UIImage(named: "p")))
        
        let imageLocker = UIImageView(image: UIImage(named: "locker"))
        imageLocker.translatesAutoresizingMaskIntoConstraints = false
        imageLocker.center = blockedView.center
        blockedView.addSubview(imageLocker)
        blockedView.alpha = 0.8
        addConstraintsIcon(icon: imageLocker, view: blockedView)
        
        return blockedView
    }
    
    class func addConstraintsIcon(icon: UIImageView, view: UIView) {
        
        let views = ["icon": icon]
        
        view.addConstraint(NSLayoutConstraint.init(
            item: icon,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0)
        )
        
        view.addConstraint(NSLayoutConstraint.init(
            item: icon,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0)
        )
        
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
