//
//  UIViewExtension.swift
//  OCM
//
//  Created by José Estela on 6/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

struct ViewMargin {
    var top: CGFloat?
    var bottom: CGFloat?
    var left: CGFloat?
    var right: CGFloat?
    
    init(top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}

extension UIView {
    
    /// Add a snapshot of the given viewcontroller (this method removes parent view controller before adding the snapshot view and set again when it finish)
    ///
    /// - Parameter viewController: The view controller to be snapshotted
    /// - Return The snapshot
    func addSnapshot(of viewController: UIViewController, with frame: CGRect? = nil) {
        let parent = viewController.parent
        viewController.removeFromParentViewController()
        let snapshot = viewController.view.snapshotView(afterScreenUpdates: true)
        if let frame = frame {
            snapshot?.frame = frame
        }
        if let snapshot = snapshot {
            self.addSubview(snapshot)
        }
        parent?.addChildViewController(viewController)
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
    
    func addSubViewWithAutoLayout(view: UIView, withMargin margin: ViewMargin, at index: Int = 0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(view, at: index)
        if let top = margin.top {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: top)
            )
        }
        if let bottom = margin.bottom {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: bottom)
            )
        }
        if let left = margin.left {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: left)
            )
        }
        if let right = margin.right {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: right)
            )
        }
    }
}
