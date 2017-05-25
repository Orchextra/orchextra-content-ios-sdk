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
    @objc optional func presentationBefore()
    @objc optional func presentationAnimation(percentComplete: CGFloat)
    @objc optional func presentationCancelAnimation()
    @objc optional func presentationCompletion(completeTransition: Bool)
    @objc optional func dismissalBeforeAction()
    @objc optional func dismissalAnimationAction(percentComplete: CGFloat)
    @objc optional func dismissalCancelAnimationAction()
    @objc optional func dismissalCompletionAction(completeTransition: Bool)
}

class ZoomImageTransition: Transition {
    
    // MARK: - Attributes
    
    var fromSnapshot: UIView?
    
    // MARK: - Init method
    
    init(snapshot: UIView?) {
        self.fromSnapshot = snapshot
    }
    
    // MARK: - Transition
    
    func animatePresenting(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = TransitionAnimator(operationType: .present, fromVC: fromVC, toVC: toVC)
        
        if  let sourceTransition = fromVC as? ImageTransitionZoomable,
            let destinationTransition = toVC as? ImageTransitionZoomable {
            
            animator.presentationBeforeHandler = { [unowned animator] (containerView, transitionContext) in
                
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
                    
                    sourceImageView.image = destinationImageView.image
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
        }
        return animator
    }
    
    func animateDismissing(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = TransitionAnimator(operationType: .dismiss, fromVC: fromVC, toVC: toVC)
        
        if  let sourceTransition = fromVC as? ImageTransitionZoomable,
            let destinationTransition = toVC as? ImageTransitionZoomable {
            
            sourceTransition.dismissalCompletionAction?(completeTransition: true)
            destinationTransition.dismissalCompletionAction?(completeTransition: true)
            
            
            animator.dismissalBeforeHandler = { [unowned animator] (containerView, transitionContext) in
                
                if let snapshot = self.fromSnapshot {
                    containerView.addSubview(snapshot)
                } else {
                    containerView.addSnapshot(of: toVC)
                }

                
                let sourceImageView = sourceTransition.createTransitionImageView()
                let destinationImageView = destinationTransition.createTransitionImageView()
                
                containerView.addSubview(sourceImageView)
                
                let yOffset = self.positionY(fromView: fromVC.view.frame, container: toVC.view.frame)
                destinationImageView.frame.origin.y += yOffset
                
                sourceTransition.dismissalBeforeAction?()
                destinationTransition.dismissalBeforeAction?()
                
                animator.dismissalAnimationHandler = { containerView, percentComplete in
                    sourceImageView.image = destinationImageView.image
                    sourceImageView.frame = destinationImageView.frame
                    fromVC.view.alpha = 0.0
                    
                    sourceTransition.dismissalAnimationAction?(percentComplete: percentComplete)
                    destinationTransition.dismissalAnimationAction?(percentComplete: percentComplete)
                }
                
                animator.dismissalCompletionHandler = { containerView, completeTransition in
                    if !completeTransition { return }
                    
                    sourceTransition.dismissalCompletionAction?(completeTransition: completeTransition)
                    destinationTransition.dismissalCompletionAction?(completeTransition: completeTransition)
                    
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        sourceImageView.alpha = 0.0
                    }, completion: { _ in
                        sourceImageView.removeFromSuperview()
                        fromVC.view.removeFromSuperview()
                    })
                    
                }
            }
        }
        return animator

    }
    
    // MARK: - Private methods
    
    private func positionY(fromView: CGRect, container: CGRect) -> CGFloat {
        let margingY = fromView.size.height - container.size.height
        return margingY
    }
    
}
