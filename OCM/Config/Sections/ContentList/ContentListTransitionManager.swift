//
//  ContentListTransitionManager.swift
//  OCM
//
//  Created by José Estela on 24/5/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class ContentListTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    
    // MARK: - Attributes
    
    weak var contentListVC: ContentListVC!
    weak var mainContentVC: MainContentViewController!
    var mainContentVCSnapshot: UIView?
    
    // MARK: - Init
    
    init(contentListVC: ContentListVC, mainContentVC: MainContentViewController) {
        self.contentListVC = contentListVC
        self.mainContentVC = mainContentVC
        super.init()
        self.mainContentVC.transitioningDelegate = self
    }
    
    // MARK: - Animation methods
    
    func transitionForPresenting() -> Transition? {
        self.mainContentVCSnapshot = UIView(frame: self.contentListVC.view.bounds)
        self.mainContentVCSnapshot?.addSubview(UIImageView(image: UIApplication.shared.takeScreenshot()))
        var transition: Transition?
        if let type = self.contentListVC.layout?.type {
            switch type {
            case .carousel:
                transition = DefaultTransition()
            case .mosaic:
                if self.mainContentVC.action?.preview != nil {
                    transition = ZoomImageTransition(snapshot: self.mainContentVCSnapshot)
                } else {
                    transition = LateralTransition(snapshot: self.mainContentVCSnapshot)
                }
            }
        }
        return transition
    }
    
    func transitionForDismissing() -> Transition? {
        var transition: Transition?
        if let type = self.contentListVC.layout?.type {
            switch type {
            case .carousel:
                transition = DefaultTransition()
            case .mosaic:
                if self.mainContentVC.currentlyViewing == .preview {
                    transition = ZoomImageTransition(snapshot: self.mainContentVCSnapshot)
                } else {
                    transition = LateralTransition(snapshot: self.mainContentVCSnapshot)
                    // Force to notify that the transition of dismiss is finished, we need to show the image in grid if we had been hide it
                    self.contentListVC.dismissalCompletionAction(completeTransition: true)
                }
            }
        }
        return transition
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionForPresenting()?.animatePresenting(presented, from: self.contentListVC)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transitionForDismissing()?.animateDismissing(self.contentListVC, from: self.mainContentVC)
    }
}
