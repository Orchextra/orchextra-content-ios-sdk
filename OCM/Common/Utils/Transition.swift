//
//  Transition.swift
//  OCM
//
//  Created by José Estela on 24/5/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

protocol Transition {
    
    /// Method to create the present animation
    ///
    /// - Parameters:
    ///   - toVC: The view controller to show
    ///   - fromVC: Current view controller
    /// - Returns: An animator or nil
    func animatePresenting(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    /// Method to create the dismiss animation
    ///
    /// - Parameters:
    ///   - toVC: The view controller destination (after dismiss)
    ///   - fromVC: Current view controller to dismiss
    /// - Returns: An animator or nil
    func animateDismissing(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
}

class DefaultTransition: Transition {
    
    func animatePresenting(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func animateDismissing(_ toVC: UIViewController, from fromVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
