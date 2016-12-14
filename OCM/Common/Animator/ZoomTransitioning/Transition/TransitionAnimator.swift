//
//  TransitionAnimator.swift
//  OCM
//
//  Created by Judith Medina on 13/12/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

public enum TransitionAnimatorDirection: Int {
    case Top
    case Bottom
    case Left
    case Right
}

public enum TransitionAnimatorOperation: Int {
    case None
    case Push
    case Pop
    case Present
    case Dismiss
}

public class TransitionAnimator: UIPercentDrivenInteractiveTransition {

    // Animation Settings
    public var usingSpringWithDamping: CGFloat = 0.78
    public var transitionDuration: TimeInterval = 0.5
    public var initialSpringVelocity: CGFloat = 0.4
    public var useKeyframeAnimation: Bool = false
    
    // Interactive Transition Gesture
    public weak var gestureTargetView: UIView? {
        willSet {
            self.unregisterPanGesture()
        }
        didSet {
            self.registerPanGesture()
        }
    }
    public var panCompletionThreshold: CGFloat = 100.0
    public var direction: TransitionAnimatorDirection = .Bottom
    public var contentScrollView: UIScrollView?
    public var interactiveType: TransitionAnimatorOperation = .None {
        didSet {
            if self.interactiveType == .None {
                self.unregisterPanGesture()
            } else {
                self.registerPanGesture()
            }
        }
    }

    // Handlers
    public var presentationBeforeHandler : ((_ containerView: UIView, _ transitionContext: UIViewControllerContextTransitioning) ->())?
    public var presentationAnimationHandler : ((_ containerView: UIView, _ percentComplete: CGFloat) ->())?
    public var presentationCancelAnimationHandler : ((_ containerView: UIView) ->())?
    public var presentationCompletionHandler : ((_ containerView: UIView, _ completeTransition: Bool) ->())?
    
    public var dismissalBeforeHandler : ((_ containerView: UIView, _ transitionContext: UIViewControllerContextTransitioning) ->())?
    public var dismissalAnimationHandler : ((_ containerView: UIView, _ percentComplete: CGFloat) ->())?
    public var dismissalCancelAnimationHandler : ((_ containerView: UIView) ->())?
    public var dismissalCompletionHandler : ((_ containerView: UIView, _ completeTransition: Bool) ->())?
    
    // Private
    fileprivate weak var fromVC: UIViewController!
    fileprivate weak var toVC: UIViewController!
    
    fileprivate(set) var operationType: TransitionAnimatorOperation
    fileprivate(set) var isPresenting: Bool = true
    fileprivate(set) var isTransitioning: Bool = false
    
    fileprivate var gesture: UIPanGestureRecognizer?
    fileprivate var transitionContext: UIViewControllerContextTransitioning?
    fileprivate var panLocationStart: CGFloat = 0.0
    
    deinit {
        self.unregisterPanGesture()
    }
    
    // MARK: - Constructor
    public init(operationType: TransitionAnimatorOperation, fromVC: UIViewController, toVC: UIViewController) {
        self.operationType = operationType
        self.fromVC = fromVC
        self.toVC = toVC
        
        switch self.operationType {
        case .Push, .Present:
            self.isPresenting = true
        case .Pop, .Dismiss:
            self.isPresenting = false
        case .None:
            break
        }
    }
    
    // MARK: - Private Functions
    
    fileprivate func registerPanGesture() {
        self.unregisterPanGesture()
        
        self.gesture = UIPanGestureRecognizer(target: self, action: Selector(("handlePan:")))
        self.gesture!.delegate = self
        self.gesture!.maximumNumberOfTouches = 1
        
        if let _gestureTargetView = self.gestureTargetView {
            _gestureTargetView.addGestureRecognizer(self.gesture!)
        } else {
            switch self.interactiveType {
            case .Push, .Present:
                self.fromVC.view.addGestureRecognizer(self.gesture!)
            case .Pop, .Dismiss:
                self.toVC.view.addGestureRecognizer(self.gesture!)
            case .None:
                break
            }
        }
    }
    
    fileprivate func unregisterPanGesture() {
        if let _gesture = self.gesture {
            if let _view = _gesture.view {
                _view.removeGestureRecognizer(_gesture)
            }
            _gesture.delegate = nil
        }
        self.gesture = nil
    }
    
    fileprivate func fireBeforeHandler(containerView: UIView, transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            self.presentationBeforeHandler?(containerView, transitionContext)
        } else {
            self.dismissalBeforeHandler?(containerView, transitionContext)
        }
    }
    
    fileprivate func fireAnimationHandler(containerView: UIView, percentComplete: CGFloat) {
        if self.isPresenting {
            self.presentationAnimationHandler?(containerView, percentComplete)
        } else {
            self.dismissalAnimationHandler?(containerView, percentComplete)
        }
    }
    
    fileprivate func fireCancelAnimationHandler(containerView: UIView) {
        if self.isPresenting {
            self.presentationCancelAnimationHandler?(containerView)
        } else {
            self.dismissalCancelAnimationHandler?(containerView)
        }
    }
    
    fileprivate func fireCompletionHandler(containerView: UIView, completeTransition: Bool) {
        if self.isPresenting {
            self.presentationCompletionHandler?(containerView, completeTransition)
        } else {
            self.dismissalCompletionHandler?(containerView, completeTransition)
        }
    }
    
    fileprivate func animateWithDuration(duration: TimeInterval, containerView: UIView, completeTransition: Bool, completion: (() -> Void)?) {
        if !self.useKeyframeAnimation {
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: self.usingSpringWithDamping,
                initialSpringVelocity: self.initialSpringVelocity,
                options: .curveEaseOut,
                animations: {
                    if completeTransition {
                        self.fireAnimationHandler(containerView: containerView, percentComplete: 1.0)
                    } else {
                        self.fireCancelAnimationHandler(containerView: containerView)
                    }
            }, completion: { finished in
                self.fireCompletionHandler(containerView: containerView, completeTransition: completeTransition)
                completion?()
            })
        } else {
            UIView.animateKeyframes(
                withDuration: duration,
                delay: 0.0,
                options: .beginFromCurrentState,
                animations: {
                    if completeTransition {
                        self.fireAnimationHandler(containerView: containerView, percentComplete: 1.0)
                    } else {
                        self.fireCancelAnimationHandler(containerView: containerView)
                    }
            }, completion: { finished in
                self.fireCompletionHandler(containerView: containerView, completeTransition: completeTransition)
                completion?()
            })
        }
    }
}

// MARK: - Interactive Transition Gesture

extension TransitionAnimator {
    
    public func handlePan(recognizer: UIPanGestureRecognizer) {
        var window: UIWindow? = nil
        
        switch self.interactiveType {
        case .Push, .Present:
            window = self.fromVC.view.window
        case .Pop, .Dismiss:
            window = self.toVC.view.window
        case .None:
            return
        }
        
        var location = recognizer.location(in: window)
        location = location.applying(recognizer.view!.transform.inverted())
        var velocity = recognizer .velocity(in: window)
        velocity = velocity.applying(recognizer.view!.transform.inverted())
        
        if recognizer.state == .began {
            self.handlePanBegan(location: location)
        } else if recognizer.state == .changed {
            self.handlePanChanged(location: location)
        } else if recognizer.state == .ended {
            self.handlePanEnd(location: location, velocity: velocity)
        } else {
            self.resetGestureTransitionSetting()
            if self.isTransitioning {
                self.cancelInteractiveTransitionAnimated(animated: true)
            }
        }
    }

    fileprivate func startGestureTransition() {
        if self.isTransitioning == false {
            self.isTransitioning = true
            switch self.interactiveType {
            case .Push:
                self.fromVC.navigationController?.pushViewController(self.toVC, animated: true)
            case .Present:
                self.fromVC.present(self.toVC, animated: true, completion: nil)
            case .Pop:
                _ = self.toVC.navigationController?.popViewController(animated: true)
            case .Dismiss:
                self.toVC.dismiss(animated: true, completion: nil)
            case .None:
                break
            }
        }
    }
    
    fileprivate func resetGestureTransitionSetting() {
        self.isTransitioning = false
    }
    
    fileprivate func setPanStartPoint(location: CGPoint) {
        switch self.direction {
        case .Top, .Bottom:
            self.panLocationStart = location.y
        case .Left, .Right:
            self.panLocationStart = location.x
        }
    }
    
    fileprivate func handlePanBegan(location: CGPoint) {
        self.setPanStartPoint(location: location)
        
        if let _contentScrollView = self.contentScrollView {
            if _contentScrollView.contentOffset.y <= 0.0 {
                self.startGestureTransition()
            }
        } else {
            self.startGestureTransition()
        }
    }
    
    fileprivate func handlePanChanged(location: CGPoint) {
        var bounds = CGRect.zero
        switch self.interactiveType {
        case .Push, .Present:
            bounds = self.fromVC.view.bounds
        case .Pop, .Dismiss:
            bounds = self.toVC.view.bounds
        case .None:
            break
        }
        
        var animationRatio: CGFloat = 0.0
        switch self.direction {
        case .Top:
            animationRatio = (self.panLocationStart - location.y) / bounds.height
        case .Bottom:
            animationRatio = (location.y - self.panLocationStart) / bounds.height
        case .Left:
            animationRatio = (self.panLocationStart - location.x) / bounds.width
        case .Right:
            animationRatio = (location.x - self.panLocationStart) / bounds.width
        }
        
        if let _contentScrollView = self.contentScrollView {
            if self.isTransitioning == false && _contentScrollView.contentOffset.y <= 0 {
                self.setPanStartPoint(location: location)
                self.startGestureTransition()
            } else {
                self.update(animationRatio)
            }
        } else {
            self.update(animationRatio)
        }
    }
        
    fileprivate func handlePanEnd(location: CGPoint, velocity: CGPoint) {
        var velocityForSelectedDirection: CGFloat = 0.0
        switch self.direction {
        case .Top, .Bottom:
            velocityForSelectedDirection = velocity.y
        case .Left, .Right:
            velocityForSelectedDirection = velocity.x
        }
        
        if velocityForSelectedDirection > self.panCompletionThreshold && (self.direction == .Right || self.direction == .Bottom) {
            self.finishInteractiveTransitionAnimated(animated: true)
        } else if velocityForSelectedDirection < -self.panCompletionThreshold && (self.direction == .Left || self.direction == .Top) {
            self.finishInteractiveTransitionAnimated(animated: true)
        } else {
            let animated = (self.contentScrollView?.contentOffset.y)! <= CGFloat(0)
            self.cancelInteractiveTransitionAnimated(animated: animated)
        }
        self.resetGestureTransitionSetting()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        self.transitionContext = transitionContext
        self.fireBeforeHandler(containerView: containerView, transitionContext: transitionContext)
        self.animateWithDuration(
            duration: self.transitionDuration(using: transitionContext),
            containerView: containerView,
            completeTransition: true) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        self.transitionContext = nil
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension TransitionAnimator: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.gesture != nil && (self.interactiveType == .Pop || self.interactiveType == .Dismiss) {
            self.isPresenting = false
            return self
        }
        return nil
    }
}

// MARK: - UIViewControllerInteractiveTransitioning

extension TransitionAnimator {
    
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        // FIXME : UINavigationController not called animator UIViewControllerTransitioningDelegate
        switch self.interactiveType {
        case .Push, .Present:
            self.isPresenting = true
        case .Pop, .Dismiss:
            self.isPresenting = false
        case .None:
            break
        }
        
        self.transitionContext = transitionContext
        self.fireBeforeHandler(containerView: containerView, transitionContext: transitionContext)
    }
}

// MARK: - UIPercentDrivenInteractiveTransition

extension TransitionAnimator {
    
    public override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        if let transitionContext = self.transitionContext {
            let containerView = transitionContext.containerView
            self.fireAnimationHandler(containerView: containerView, percentComplete: percentComplete)
        }
    }
    
    public func finishInteractiveTransitionAnimated(animated: Bool) {
        super.finish()
        if let transitionContext = self.transitionContext {
            let containerView = transitionContext.containerView
            self.animateWithDuration(
                duration: animated ? self.transitionDuration(using: transitionContext) : 0,
                containerView: containerView,
                completeTransition: true) {
                    transitionContext.completeTransition(true)
            }
        }
    }
    
    public func cancelInteractiveTransitionAnimated(animated: Bool) {
        super.cancel()
        if let transitionContext = self.transitionContext {
            let containerView = transitionContext.containerView
            self.animateWithDuration(
                duration: animated ? self.transitionDuration(using: transitionContext) : 0,
                containerView: containerView,
                completeTransition: false) {
                    transitionContext.completeTransition(false)
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension TransitionAnimator: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.contentScrollView != nil ? true : false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
