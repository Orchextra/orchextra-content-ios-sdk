//
//  ModalImageTransitionViewController.swift
//  OCM
//
//  Created by Judith Medina on 13/12/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class ModalImageTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
  
    weak var fromVC: UIViewController?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ImageTransition.createAnimator(operationType: .Present, fromVC: source, toVC: presented)
        self.fromVC = source
        
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ImageTransition.createAnimator(operationType: .Dismiss, fromVC: self, toVC: self.fromVC!)        
        return animator
    }

}
