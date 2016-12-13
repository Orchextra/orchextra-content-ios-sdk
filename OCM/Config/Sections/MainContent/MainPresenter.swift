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
    func makeShareButtons(visible: Bool)
    func share(url: String)
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
        
        if (action.view()) != nil || (preview != nil) {
            viewController?.show(preview: preview, action: action)
            viewController?.makeShareButtons(visible: action.shareUrl != nil)
        } else {
            action.executable()
        }
    }
    
    func userDidShare() {
        guard let shareUrl = action.shareUrl else { return }
        self.viewController?.share(url: shareUrl)
    }
}
