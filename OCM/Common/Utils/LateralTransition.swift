//
//  LateralTransition.swift
//  OCM
//
//  Created by José Estela on 24/5/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class LateralTransition: Transition {
    
    // MARK: - Attributes
    
    var fromSnapshot: UIView?
    
    // MARK: - Init method
    
    init(snapshot: UIView?) {
        self.fromSnapshot = snapshot
    }
    
    // MARK: - Transition
    
    func animatePresenting(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = TransitionAnimator(operationType: .present, fromVC: fromVC, toVC: toVC)
        animator.presentationBeforeHandler = { [unowned animator] (containerView, transitionContext) in
            guard let fromView = fromVC.view, let toView = toVC.view else { return }
            
            if let snapshot = self.fromSnapshot {
                containerView.addSubview(snapshot)
            } else {
                containerView.addSubview(fromView)
            }
            
            containerView.addSubview(toView)
            
            let offScreenRight = CGAffineTransform(translationX: containerView.frame.width, y: 0)
            toView.transform = offScreenRight
            
            animator.presentationAnimationHandler = { containerView, percentComplete in
                UIView.animate(withDuration: 0.5) {
                    toView.transform = .identity
                }
            }
        }
        return animator
    }
    
    func animateDismissing(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = TransitionAnimator(operationType: .dismiss, fromVC: fromVC, toVC: toVC)
        animator.dismissalBeforeHandler = {  [unowned animator] (containerView, transitionContext) in
            guard let fromView = fromVC.view, var toView = toVC.view else { return }
            
            if let snapshot = self.fromSnapshot {
                toView = snapshot
            }
            
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            
            animator.dismissalAnimationHandler = { containerView, percentComplete in
                fromView.frame = CGRect(origin: CGPoint(x: containerView.frame.width * percentComplete, y: fromView.y()), size: fromView.frame.size)
            }
        }
        
        return animator
    }
}
