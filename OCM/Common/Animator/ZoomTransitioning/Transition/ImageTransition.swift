//
//  ImageTransition.swift
//  OCM
//
//  Created by Judith Medina on 13/12/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

@objc protocol ImageTransitionZoomable {

    func createTransitionImageView() -> UIImageView

    @objc optional
    func presentationBefore()
    @objc optional
    func presentationAnimation(percentComplete: CGFloat)
    @objc optional
    func presentationCancelAnimation()
    @objc optional
    func presentationCompletion(completeTransition: Bool)
    @objc optional
    func dismissalBeforeAction()
    @objc optional
    func dismissalAnimationAction(percentComplete: CGFloat)
    @objc optional
    func dismissalCancelAnimationAction()
    @objc optional
    func dismissalCompletionAction(completeTransition: Bool)
}

class ImageTransition {
    
    class func createAnimator(operationType: TransitionAnimatorOperation, fromVC: UIViewController, toVC: UIViewController) -> TransitionAnimator {

        let animator = TransitionAnimator(operationType: operationType, fromVC: fromVC, toVC: toVC)
        
        if let sourceTransition = fromVC as? ImageTransitionZoomable, let destinationTransition = toVC as? ImageTransitionZoomable {
            
            animator.presentationBeforeHandler = { containerView, transitionContext in
                containerView.addSubview(toVC.view)
                
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                let sourceImageView = sourceTransition.createTransitionImageView()
                let destinationImageView = destinationTransition.createTransitionImageView()
                
                containerView.addSubview(sourceImageView)
                
                sourceTransition.presentationBefore?()
                destinationTransition.presentationBefore?()
                
                toVC.view.alpha = 0.0
                
                animator.presentationAnimationHandler = { containerView, percentComplete in
                    sourceImageView.frame = destinationImageView.frame
                    
                    toVC.view.alpha = 1.0
                    
                    sourceTransition.presentationAnimation?(percentComplete: percentComplete)
                    destinationTransition.presentationAnimation?(percentComplete: percentComplete)
                }
                
                animator.presentationCompletionHandler = { containerView, completeTransition in
                    if !completeTransition { return }
                    
                    sourceImageView.removeFromSuperview()
                    sourceTransition.presentationCompletion?(completeTransition: completeTransition)
                    destinationTransition.presentationCompletion?(completeTransition: completeTransition)
                }
            }
            
            animator.dismissalBeforeHandler = { containerView, transitionContext in
                if case .Dismiss = operationType {
                    containerView.addSubview(toVC.navigationController!.view)
                } else {
                    containerView.addSubview(toVC.view)
                }
                containerView.addSubview(fromVC.view)
                
                let sourceImageView = sourceTransition.createTransitionImageView()
                let destinationImageView = destinationTransition.createTransitionImageView()
                containerView.addSubview(sourceImageView)
                
                sourceTransition.dismissalBeforeAction?()
                destinationTransition.dismissalBeforeAction?()
                
                animator.dismissalAnimationHandler = { containerView, percentComplete in
                    sourceImageView.frame = destinationImageView.frame
                    fromVC.view.alpha = 0.0
                    
                    sourceTransition.dismissalAnimationAction?(percentComplete: percentComplete)
                    destinationTransition.dismissalAnimationAction?(percentComplete: percentComplete)
                }
                
                animator.dismissalCompletionHandler = { containerView, completeTransition in
                    if !completeTransition { return }
                    
                    sourceImageView.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    
                    sourceTransition.dismissalCompletionAction?(completeTransition: completeTransition)
                    destinationTransition.dismissalCompletionAction?(completeTransition: completeTransition)
                }
            }
        }
        
        return animator
    }
    
}
