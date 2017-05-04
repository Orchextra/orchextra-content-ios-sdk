//
//  MainPresenter.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol MainContentUI: class {
    func show(preview: Preview?, action: Action)
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
            self.view?.show(preview: preview, action: action)
            self.view?.makeShareButtons(visible: action.shareInfo != nil)
        } else {
            action.executable()
        }
    }
    
    func userDidShare() {
        guard let shareInfo = action.shareInfo else { return }
        if let actionIdentifier = self.action.identifier {
            // Notified to analytic delegate that the user wants to share a content
            OCM.shared.analytics?.track(
                with: [
                    AnalyticConstants.kAction: AnalyticConstants.kSharing,
                    AnalyticConstants.kType: AnalyticConstants.kTap,
                    AnalyticConstants.kContentType: Content.contentType(of: actionIdentifier) ?? "",
                    AnalyticConstants.kValue: self.action.identifier ?? ""
                ]
            )
        }
        self.view?.share(shareInfo)
    }
    
    func userDidFinishContent() {
        // Nothing to do here
    }
}
