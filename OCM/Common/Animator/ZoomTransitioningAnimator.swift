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
    public var frameContainer = CGRect.zero
    public let transtionDuration = 0.4
    public var presenting = true
    public var interactive = false
    private var originalSnapshot: UIImageView?
    
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
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else { return }
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        let yOffset = positionY(fromView: fromVC.view.frame, container:frameContainer, cellframe: originFrame)

        var cellFrame = originFrame
        cellFrame.origin.y += yOffset
        let snapshot = fromVC.view.snapshot(of: cellFrame)
        let viewSnapshot = UIImageView(image: snapshot)
        viewSnapshot.frame = cellFrame
        self.originalSnapshot = UIImageView()
        self.originalSnapshot = viewSnapshot
    
        containerView.addSubview(fromVC.view)
        containerView.addSubview(viewSnapshot)
        
        UIView.animate(
            withDuration: self.transtionDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.9,
            options: .curveEaseInOut,
            animations: {
                viewSnapshot.frame = finalFrame
        }, completion: { finished in
            
            let views = (frontView: viewSnapshot, backView: toVC.view)
            UIView.transition(with: containerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                views.frontView.removeFromSuperview()
                containerView.addSubview(views.backView)
            }, completion: { finished in
            })
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func dismissView(transitionContext: UIViewControllerContextTransitioning) {
    
        let containerView = transitionContext.containerView
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else { return }
        
        let yOffset = positionY(fromView: fromVC.view.frame, container:frameContainer, cellframe: originFrame)
        
        var cellFrame = originFrame
        cellFrame.origin.y += yOffset

        let snapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot!)
        
        UIView.animate(
            withDuration: self.transtionDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.9,
            options: .curveEaseInOut,
            animations: {
                snapshot?.frame = cellFrame
        }, completion: { finished in
            
            let views = (frontView: snapshot!, backView: toVC.view)
            
            UIView.transition(with: containerView, duration: 0.8, options: .transitionCrossDissolve, animations: {
                views.frontView.removeFromSuperview()
                containerView.addSubview(views.backView)
            }, completion: { finished in
            })
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func positionY(fromView: CGRect, container: CGRect, cellframe: CGRect) -> CGFloat {
        
        let margingY = fromView.size.height - container.size.height
        return margingY
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
