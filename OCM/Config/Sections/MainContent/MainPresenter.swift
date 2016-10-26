//
//  MainPresenter.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol PMainContent {
 
    func show(preview: Preview?, action: Action)
}

class MainPresenter: NSObject {

    var viewController: PMainContent?
    
    var preview: Preview?
    let action: Action
    
    init(action: Action) {
        
        self.preview = action.preview
        self.action = action
    }
    
    func viewIsReady() {
        
        if (action.view()) != nil {
            viewController?.show(preview: preview, action: action)
        } else {
            action.executable()
        }
    }
}
