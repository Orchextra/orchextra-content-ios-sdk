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
        
        if  let sourceTransition = fromVC as? ImageTransitionZoomable,
            let destinationTransition = toVC as? ImageTransitionZoomable {
            
            animator.presentationBeforeHandler = { containerView, transitionContext in
                self.presentAnimation(animator: animator, transition: (sourceTransition, destinationTransition), viewController: (from: fromVC, to: toVC), containerView: containerView)
            }
            
            animator.dismissalBeforeHandler = { containerView, transitionContext in
                self.dismissAnimation(animator: animator, transition: (sourceTransition, destinationTransition), viewController: (from: fromVC, to: toVC), containerView: containerView, operationType: operationType)
            }
        }
        
        return animator
    }
    
    class func presentAnimation(animator: TransitionAnimator,
                                transition: (source: ImageTransitionZoomable, destination: ImageTransitionZoomable),
                                viewController: (from: UIViewController, to: UIViewController),
                                containerView: UIView) {
        
        containerView.addSubview(viewController.to.view)
        
        viewController.to.view.setNeedsLayout()
        viewController.to.view.layoutIfNeeded()
        
        let sourceImageView = transition.source.createTransitionImageView()
        let destinationImageView = transition.destination.createTransitionImageView()
        containerView.addSubview(sourceImageView)
        
        transition.source.presentationBefore?()
        transition.destination.presentationBefore?()
        
        viewController.to.view.alpha = 0.0
        
        animator.presentationAnimationHandler = { containerView, percentComplete in
            
            sourceImageView.image = destinationImageView.image
            sourceImageView.frame = destinationImageView.frame
            viewController.to.view.alpha = 1.0
            
            transition.source.presentationAnimation?(percentComplete: percentComplete)
            transition.destination.presentationAnimation?(percentComplete: percentComplete)
        }
        
        animator.presentationCompletionHandler = { containerView, completeTransition in
            if !completeTransition { return }
            sourceImageView.removeFromSuperview()
            transition.source.presentationCompletion?(completeTransition: completeTransition)
            transition.destination.presentationCompletion?(completeTransition: completeTransition)
        }
    }
        
    class func dismissAnimation(animator: TransitionAnimator,
                                transition: (source: ImageTransitionZoomable, destination: ImageTransitionZoomable),
                                viewController: (from: UIViewController, to: UIViewController),
                                containerView: UIView, operationType: TransitionAnimatorOperation) {
        
        if case .Dismiss = operationType {
            containerView.addSubview(viewController.to.navigationController!.view)
        } else {
            containerView.addSubview(viewController.to.view)
        }
        containerView.addSubview(viewController.from.view)
        
        let sourceImageView = transition.source.createTransitionImageView()
        let destinationImageView = transition.destination.createTransitionImageView()
        containerView.addSubview(sourceImageView)
        
        let yOffset = positionY(fromView: viewController.from.view.frame, container: viewController.to.view.frame)
        destinationImageView.frame.origin.y += yOffset
        
        transition.source.dismissalBeforeAction?()
        transition.destination.dismissalBeforeAction?()
        
        animator.dismissalAnimationHandler = { containerView, percentComplete in
            sourceImageView.image = destinationImageView.image
            sourceImageView.frame = destinationImageView.frame
            viewController.from.view.alpha = 0.0
            
            transition.source.dismissalAnimationAction?(percentComplete: percentComplete)
            transition.destination.dismissalAnimationAction?(percentComplete: percentComplete)
        }
        
        animator.dismissalCompletionHandler = { containerView, completeTransition in
            if !completeTransition { return }
            
            transition.source.dismissalCompletionAction?(completeTransition: completeTransition)
            transition.destination.dismissalCompletionAction?(completeTransition: completeTransition)
            
            
            UIView.animate(withDuration: 0.3, animations: {
                sourceImageView.alpha = 0.0
            }, completion: { finish in
                sourceImageView.removeFromSuperview()
                viewController.from.view.removeFromSuperview()
            })
            
        }
    }
    
    class func positionY(fromView: CGRect, container: CGRect) -> CGFloat {
        let margingY = fromView.size.height - container.size.height
        return margingY
    }
    
}
