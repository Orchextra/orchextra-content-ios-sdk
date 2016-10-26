//
//  UIViewController+Extension.swift
//  OCM
//
//  Created by Sergio López on 26/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

extension UIViewController {
    @objc func hide() {
        if let presentingVC = targetViewController(forAction: #selector(hide), sender: nil) {
            presentingVC.hide()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UINavigationController {
    @objc override func hide() {
        popViewController(animated: true)
    }
}
