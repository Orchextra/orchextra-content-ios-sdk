//
//  LoadingView.swift
//  OCM
//
//  Created by Carlos Vicente on 15/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class LoadingView: StatusView {
    
    // MARK: StatusView protocol
    
    func instantiate() -> UIView {
        let kTopMargin = 112
        let kBottomMargin = 12
        let loadingView = UIView(frame: .zero)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.backgroundColor = UIColor.OCM.gray
        let activityIndicatorView = self.activityIndicatorView()
        loadingView.addSubview(activityIndicatorView)
        
        let views   = ["loadingView"           : loadingView,
                       "activityIndicatorView" : activityIndicatorView]
        let metrics = ["topMargin" : kTopMargin,
                       "bottomMargin" : kBottomMargin]
        
        loadingView.addConstraint(
            NSLayoutConstraint(
                item: activityIndicatorView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: loadingView,
                attribute: .centerX,
                multiplier: 1,
                constant: 0)
        )
        
        loadingView.addConstraint(
            NSLayoutConstraint(
                item: activityIndicatorView,
                attribute: .width,
                relatedBy: .equal,
                toItem: loadingView,
                attribute: .width,
                multiplier: 1,
                constant: 0)
        )
        
        loadingView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-topMargin-[activityIndicatorView]-(>=bottomMargin)-|",
                options: .alignAllTrailing,
                metrics: metrics,
                views: views
            )
        )
        
        return loadingView
    }
    
    // MARK: Private methods
    
    fileprivate func activityIndicator() -> UIImageView {
        let activityIndicator = UIImageView(image: UIImage.OCM.loading)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = 2.0
        activityIndicator.layer.add(rotateAnimation, forKey: nil)
        
        return activityIndicator
    }
    
    fileprivate func loadingLabel() -> UILabel {
        let loadingLabel = UILabel(frame: .zero)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textColor = .white
        loadingLabel.styledString = "Loading".style(.color(.white), .fontName("Helvetica-Neue"), .size(20), .letterSpacing(3.3))
        
        return loadingLabel
    }
    
    fileprivate func activityIndicatorView() -> UIView {
        let kActivityIndicatorMargin = 35
        let kBottomMargin = 6
        
        let activityIndicatorView = UIView(frame: CGRect.zero)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = self.activityIndicator()
        activityIndicatorView.addSubview(activityIndicator)
        
        let loadingLabel = self.loadingLabel()
         activityIndicatorView.addSubview(loadingLabel)
        
        let views = ["activityIndicatorView" : activityIndicatorView,
                     "loadingLabel"          : loadingLabel,
                     "activityIndicator"     : activityIndicator]
        
        let metrics = ["activityIndicatorMargin" : kActivityIndicatorMargin,
                       "bottomMargin" : kBottomMargin]
        
        activityIndicatorView.addConstraint(
            NSLayoutConstraint(
                item: activityIndicator,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: activityIndicatorView,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )
        
        activityIndicatorView.addConstraint(
            NSLayoutConstraint(
                item: loadingLabel,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: activityIndicatorView,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )

        activityIndicatorView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[activityIndicator]-(activityIndicatorMargin)-[loadingLabel]-(bottomMargin)-|",
                options: .alignAllCenterX,
                metrics: metrics,
                views: views
            )
        )
        
        return activityIndicatorView
    }
}
