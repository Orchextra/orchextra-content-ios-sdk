//
//  ZoomingAnimationController.swift
//  AnimationCells
//
//  Created by Judith Medina on 30/9/16.
//  Copyright © 2016 Gigigo Mobile Services S.L. All rights reserved.
//

import UIKit

class ZoomTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
    public var originFrame = CGRect.zero
    public let transtionDuration = 0.4
    public var presenting = true
    public var interactive = false
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transtionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if presenting {
            presentView(transitionContext: transitionContext)
        } else {
            dismissView(transitionContext: transitionContext)
        }
    }
    
    func presentView(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else { return }
        
        toVC.view.alpha = 0
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let snapshot = fromVC.view.snapshot(of: originFrame)
        let viewSnapshot = UIImageView(image: snapshot)
        viewSnapshot.frame = originFrame
        viewSnapshot.frame.origin.y += initialFrame.origin.y
        containerView.addSubview(fromVC.view)
        containerView.addSubview(viewSnapshot)
        containerView.addSubview(toVC.view)
        
        UIView.animate(
            withDuration: self.transtionDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.9,
            options: UIViewAnimationOptions.curveEaseInOut,
            animations: {
                viewSnapshot.frame = finalFrame
        }, completion: { finished in
            toVC.view.alpha = 1
            viewSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func dismissView(transitionContext: UIViewControllerContextTransitioning) {
    
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else { return }
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        var initialFrame = originFrame
        initialFrame.origin.y += finalFrame.origin.y
        
        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        containerView.addSubview(toVC.view)

        containerView.addSubview(snapshot!)
        
        UIView.animate(
            withDuration: self.transtionDuration,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.9,
            options: UIViewAnimationOptions.curveEaseInOut,
            animations: {
                snapshot?.frame = initialFrame
        }, completion: { finished in
            snapshot?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

extension UIView {
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
}
