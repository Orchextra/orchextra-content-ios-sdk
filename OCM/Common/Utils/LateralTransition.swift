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
            let duration = animator.transitionDuration(using: transitionContext)
            
            guard let fromView = fromVC.view, let toView = toVC.view else { return }
            
            if let snapshot = self.fromSnapshot {
                containerView.addSubview(snapshot)
            } else {
                containerView.addSubview(fromView)
            }
            
            containerView.addSubview(toView)
            
            let offScreenRight = CGAffineTransform(translationX: containerView.frame.width, y: 0)
            
            toView.transform = offScreenRight
            
            UIView.animate(withDuration: duration, animations: {
                toView.transform = .identity
            }) {  finished in
                if finished {
                    fromView.removeFromSuperview()
                    fromView.frame = toView.frame
                }
            }
        }
        return animator
    }
    
    func animateDismissing(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = TransitionAnimator(operationType: .dismiss, fromVC: fromVC, toVC: toVC)
        
        animator.dismissalBeforeHandler = {  [unowned animator] (containerView, transitionContext) in
            let duration = animator.transitionDuration(using: transitionContext)
            
            guard let fromView = fromVC.view, var toView = toVC.view else { return }
            
            if let snapshot = self.fromSnapshot {
                toView = snapshot
            }
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            
            let offScreenRight = CGAffineTransform(translationX: containerView.frame.width, y: 0)
        
            DispatchQueue.main.async {
                UIView.animate(withDuration: duration, animations: {
                    fromView.transform = offScreenRight
                }) {  finished in
                    if finished {
                        fromView.removeFromSuperview()
                        fromView.frame = toView.frame
                    }
                }
            }
        }
        
        return animator
    }
}
