//
//  ZoomingAnimationController.swift
//  AnimationCells
//
//  Created by Judith Medina on 30/9/16.
//  Copyright © 2016 Gigigo Mobile Services S.L. All rights reserved.
//

import UIKit

open class ZoomTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
    public var originFrame = CGRect.zero
    public let transtionDuration = 0.6
    public var presenting = true
    public var interactive = false
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transtionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard let toView = transitionContext.view(forKey: .to) else {return}
        
        let detailView = presenting ? toView : transitionContext.view(forKey: .from)
        guard   let initialFrame = presenting ? originFrame : detailView?.frame,
                let finalFrame = presenting ? detailView?.frame : originFrame
            else { return }
        
        
        
        let xScaleFactor = presenting ? initialFrame.width/finalFrame.width :
                                        finalFrame.width/initialFrame.width
        
        let yScaleFactor = presenting ? initialFrame.height/finalFrame.height :
                                        finalFrame.height/initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            detailView?.transform = scaleTransform
            detailView?.center = CGPoint(x: initialFrame.midX,
                                         y: initialFrame.midY)
            detailView?.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: detailView!)
        
        UIView.animate(withDuration: transtionDuration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            detailView?.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
            detailView?.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            }) { _ in
                transitionContext.completeTransition(true)
        }
    }
    
//    func handlePan(recognizer: UIPanGestureRecognizer) {
//        
//        let translation = recognizer.translation( in: recognizer.view!.superview!)
//        var progress: CGFloat = abs(translation.x / 200.0)
//        progress = min(max(progress, 0.01), 0.99)
//        
//        // how much distance have we panned in reference to the parent view?
////        let translation = recognizer.translation(in: recognizer.view!)
////        let progress =  translation.x / (recognizer.view?.bounds.width)! * 0.5
//        
//        switch recognizer.state {
//            
//        case .began:
//            self.interactive = true
//            
//        case .changed:
//            update(progress)
//        case .cancelled, .ended:
//                self.interactive = false
//            if progress < 0.5 {
//                completionSpeed = -1.0
//                cancel()
//            } else {
//                completionSpeed = 1.0
//                finish()
//            }
//        default:
//            break
//        }
//    }
    
}
