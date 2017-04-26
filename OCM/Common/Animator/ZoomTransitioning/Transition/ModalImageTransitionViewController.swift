//
//  ModalImageTransitionViewController.swift
//  OCM
//
//  Created by Judith Medina on 13/12/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class ModalImageTransitionViewController: OrchextraViewController, UIViewControllerTransitioningDelegate {
    
    weak var fromVC: UIViewController?
    var fromSnapshot: UIView?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.fromSnapshot = UIView(frame: source.view.bounds)
        self.fromSnapshot?.addSubview(UIImageView(image: UIApplication.shared.takeScreenshot()))
        
        let animator = ImageTransition.createPresentAnimator(from: source, to: presented)
        self.fromVC = source
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let fromVC = self.fromVC else {
            return nil
        }
        let animator = ImageTransition.createDismissAnimator(
            from: self,
            to: fromVC,
            with: self.fromSnapshot
        )
        return animator
    }
}
