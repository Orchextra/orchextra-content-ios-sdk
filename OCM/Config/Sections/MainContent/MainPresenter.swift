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
    
    let preview: Preview?
    let action: Action
    
    init(preview: Preview?, action: Action) {
        self.preview = preview
        self.action = action
    }
    
    func viewIsReady() {
        viewController?.show(preview: preview, action: action)
    }
}
