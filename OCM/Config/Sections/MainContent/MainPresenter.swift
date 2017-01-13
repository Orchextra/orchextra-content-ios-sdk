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
    func share(_ info: ShareInfo)
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
            viewController?.makeShareButtons(visible: action.shareInfo != nil)
        } else {
            action.executable()
        }
    }
    
    func userDidShare() {
        guard let shareInfo = action.shareInfo else { return }
        // Notified to analytic delegate that the user wants to share a content
        OCM.shared.analytics?.track(
            with: [
                AnalyticConstants.kAction: AnalyticConstants.kSharing,
                AnalyticConstants.kCategory: AnalyticConstants.kAccess
            ]
        )
        self.viewController?.share(shareInfo)
    }
    
    func userDidFinishContent() {
        // Notified when users did finish the content
        OCM.shared.analytics?.track(
            with: [
                AnalyticConstants.kAction: AnalyticConstants.kContentEnd,
                AnalyticConstants.kCategory: AnalyticConstants.kTap,
                AnalyticConstants.kValue: action.id
            ]
        )
    }
}
