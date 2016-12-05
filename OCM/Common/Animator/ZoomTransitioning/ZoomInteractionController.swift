//
//  ZoomInteractionController.swift
//  OCM
//
//  Created by Judith Medina on 1/12/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class ZoomInteractionController: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    func wire(viewController: UIViewController!) {
        self.viewController = viewController
        prepareGestureRecognizer(view: viewController.view)
    }
    
    private func prepareGestureRecognizer(view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture(gestureRecognizer:)))
        gesture.edges = .left
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
            
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
            
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        case .cancelled:
            interactionInProgress = false
            cancel()
            
        case .ended:
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }

}
