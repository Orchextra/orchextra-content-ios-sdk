//
//  PreviewViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController, PPreview {
    
    var presenter: PreviewPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Events
    
    func tapAction() {
        self.presenter?.userTappedPreview()
    }
    
    func swipeAction() {
        
    }
    
    // MARK: PPreview
    
    func show(preview: UIView) {
        self.view.addSubview(preview)
    }

}
