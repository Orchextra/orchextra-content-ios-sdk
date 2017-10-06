//
//  Spinable.swift
//  OCM
//
//  Created by  Eduardo Parada on 27/9/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct Spinable {
    
    let spinner: UIActivityIndicatorView
    let backgroundView: UIView
    
    
    init(view: UIView) {
        self.spinner = UIActivityIndicatorView(
            activityIndicatorStyle: .whiteLarge
        )
        
        self.spinner.stopAnimating()
        self.spinner.center = CGPoint(x: view.center.x, y: 200)
        self.backgroundView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width(),
                height: view.height()
            )
        )
        self.backgroundView.backgroundColor = UIColor.black
        self.backgroundView.alpha = 0
        
        view.addSubview(self.backgroundView)
        view.addSubview(self.spinner)
    }
    
    func showSpinner(show: Bool) {
        self.spinner.layer.zPosition = 2
        self.backgroundView.layer.zPosition = 1
        if show {
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.5) {
                self.backgroundView.alpha = 0.6
            }
        } else {
            self.spinner.stopAnimating()
            UIView.animate(withDuration: 0.5) {
                self.backgroundView.alpha = 0
            }
        }
    }
}
