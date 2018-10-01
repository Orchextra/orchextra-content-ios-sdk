//
//  UIViewExtension.swift
//  OCM
//
//  Created by José Estela on 6/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

import UIKit

extension UIView {
    
    /// Add a snapshot of the given viewcontroller (this method removes parent view controller before adding the snapshot view and set again when it finish)
    ///
    /// - Parameter viewController: The view controller to be snapshotted
    /// - Return The snapshot
    func addSnapshot(of viewController: UIViewController, with frame: CGRect? = nil) {
        let parent = viewController.parent
        viewController.removeFromParent()
        let snapshot = viewController.view.snapshotView(afterScreenUpdates: true)
        if let frame = frame {
            snapshot?.frame = frame
        }
        if let snapshot = snapshot {
            self.addSubview(snapshot)
        }
        parent?.addChild(viewController)
    }
    
    func snapshot() -> UIView {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let view = UIView(frame: self.bounds)
        let imageView = UIImageView(frame: self.bounds)
        imageView.image = image
        view.addSubview(imageView)
        return view
    }
}

extension UIView {
    
    func topMargin(of view: UIView) -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            ($0.firstItem as? NSObject) == view && $0.firstAttribute == .top
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }

    func bottomMargin(of view: UIView) -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            ($0.secondItem as? NSObject) == view && $0.secondAttribute == .bottom
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
    
    func leftMargin(of view: UIView) -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            ($0.firstItem as? NSObject) == view && $0.firstAttribute == .top
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
    
    func heightConstraint() -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            $0.firstAttribute == .height
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
    
    func widthConstraint() -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            $0.firstAttribute == .width
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
}

extension UIView {
    
    /// Determines if a view is visible within it's superviews bounds (recursively)
    ///
    /// - Return `true` if it's visible, `false` otherwise
    func isVisible() -> Bool {
        return self.isVisible(view: self, inView: self.superview)
    }
    
    func isVisible(view: UIView, inView: UIView?) -> Bool {
        guard let inView = inView else { return true }
        let viewFrame = inView.convert(view.bounds, from: view)
        if viewFrame.intersects(inView.bounds) {
            return isVisible(view: view, inView: inView.superview)
        }
        return false
    }
}
