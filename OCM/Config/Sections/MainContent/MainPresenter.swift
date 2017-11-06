//
//  MainPresenter.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol MainContentUI: class {
    func show(name: String?, preview: Preview?, action: Action)
    func makeShareButtons(visible: Bool)
    func share(_ info: ShareInfo)
}

class MainPresenter: NSObject {

    weak var view: MainContentUI?
    
    var preview: Preview?
    let action: Action
    
    init(action: Action) {
        
        self.preview = action.preview
        self.action = action
    }
    
    func viewIsReady() {
        
        if (action.view()) != nil || (preview != nil) {
            let title: String?
            if let actionArticle = action as? ActionArticle {
                title = actionArticle.article.name
            } else {
                title = .none
            }
            self.view?.show(name: title, preview: preview, action: action)
            self.view?.makeShareButtons(visible: action.shareInfo != nil)
        } else {
            action.executable()
        }
    }
    
    func userDidShare() {
        guard let shareInfo = action.shareInfo else { return }
        if let actionIdentifier = self.action.slug {
            // Notified to analytic delegate that the user wants to share a content
            OCM.shared.eventDelegate?.userDidShareContent(identifier: actionIdentifier, type: self.action.type ?? "")
        }
        self.view?.share(shareInfo)
    }
    
    func contentPreviewDidLoad() {
        guard let actionIdentifier = self.action.slug else { return }
        OCM.shared.eventDelegate?.contentPreviewDidLoad(identifier: actionIdentifier, type: self.action.type ?? "")
    }
    
    func contentDidLoad() {
        guard let actionIdentifier = self.action.slug else { return }
        OCM.shared.eventDelegate?.contentDidLoad(identifier: actionIdentifier, type: self.action.type ?? "")
    }
    
    func userDidFinishContent() {
        // Nothing to do here
    }
}
