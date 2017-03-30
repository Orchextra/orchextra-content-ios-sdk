//
//  ImageTransitionNavigationController.swift
//  OCM
//
//  Created by Judith Medina on 13/12/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class ImageTransitionNavigationController: UINavigationController, UINavigationControllerDelegate {
   
    weak var interactiveAnimator: TransitionAnimator?
    var currentOperation: UINavigationControllerOperation = .none
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.delegate = self
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.currentOperation = operation
        
        if let _interactiveAnimator = self.interactiveAnimator {
            return _interactiveAnimator
        }
        
        if operation == .push {
            return ImageTransition.createAnimator(operationType: .push, fromVC: fromVC, toVC: toVC)
        } else if operation == .pop {
            return ImageTransition.createAnimator(operationType: .pop, fromVC: fromVC, toVC: toVC)
        }
        
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let _interactiveAnimator = self.interactiveAnimator {
            if  self.currentOperation == .pop {
                return _interactiveAnimator
            }
        }
        return nil
    }

}
