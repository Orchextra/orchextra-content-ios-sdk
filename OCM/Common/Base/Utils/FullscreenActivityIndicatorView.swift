//
//  FullscreenActivityIndicatorView.swift
//  OCM
//
//  Created by  Eduardo Parada on 31/8/17.
//  Updated by  Jerilyn Gonçalves on 5/4/18.
//  Copyright © 2017 Gigigo Mobile Services S.L. All rights reserved.
//

import UIKit

class FullscreenActivityIndicatorView: UIView {
    
    var activityIndicator: ImageActivityIndicator?
    var isVisible: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        self.alpha = 0
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        let activityIndicator = ImageActivityIndicator(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 25)), image: UIImage.OCM.loadingIcon ?? UIImage())
        activityIndicator.tintColor = UIColor.blue
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        self.activityIndicator =  activityIndicator
    }
    
    func show(in view: UIView) {
        guard !self.isVisible else { return }
        view.addSubview(self)
        self.activityIndicator?.startAnimating()
        self.alpha = 1.0
        self.isVisible = true
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
            },
            completion: nil
        )
    }
    
    func dismiss() {
        guard self.isVisible else { return }
        self.activityIndicator?.stopAnimating()
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
            },
            completion: { (_) in
                self.alpha = 0.0
                self.isVisible = false
                self.removeFromSuperview()
            }
        )
    }
}

