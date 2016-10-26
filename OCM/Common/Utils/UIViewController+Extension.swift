//
//  UIViewController+Extension.swift
//  OCM
//
//  Created by Sergio López on 26/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

extension UIViewController {
    @objc func hideViewController(sender: AnyObject?) {
        if let presentingVC = targetViewController(forAction: #selector(hideViewController), sender: sender) {
            presentingVC.hideViewController(sender: self)
        }
    }
}

extension UINavigationController {
    @objc override func hideViewController(sender: AnyObject?) {
        popViewController(animated: true)
    }
}
