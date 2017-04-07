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
}
