//
//  ActionViewer.swift
//  OCM
//
//  Created by Eduardo Parada on 16/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

//swiftlint:disable cyclomatic_complexity

struct ActionViewer {
    var action: Action
    var ocm: OCM
    
    func view() -> OrchextraViewController? {
        switch self.action.typeAction {
        case .actionArticle:
            guard let actionArticle = self.action as? ActionArticle else { logWarn("Action doesn't is a ActionArticle"); return nil }
            return self.ocm.wireframe.loadArticle(
                with: actionArticle.article,
                elementUrl: self.action.elementUrl
            )
            
        case .actionWebview:// TODO EDU, problema, tengo que ver ocmo informar al action que tiene q actualizar el local storage
            guard let actionWebview = self.action as? ActionWebview else { logWarn("Action doesn't is a ActionWebview"); return nil }
            // actionWebview.resetLocalStorage = false
            self.action.updateLocalStorage()
            return self.ocm.wireframe.loadWebView(with: actionWebview)
            
        case .actionCard:
            guard let action =  action as? ActionCard else { logWarn("action doesn't is a ActionCard"); return nil }
            return self.ocm.wireframe.loadCards(with: action.cards)
            
        case .actionContent:
            guard let actionContent = self.action as? ActionContent else { logWarn("Action doesn't is a ActionContent"); return nil }
            return self.ocm.wireframe.loadContentList(from: actionContent.path)
            
        case .actionVideo:
            guard let action =  action as? ActionVideo else { logWarn("action doesn't is a ActionVideo"); return nil }
            
            switch action.video.format {
            case .youtube:
                return self.ocm.wireframe.loadYoutubeVC(with: action.video.source)
            default:
                return self.ocm.wireframe.loadVideoPlayerVC(with: action.video)
            }
            
        case .actionExternalBrowser, .actionBrowser, .actionScan, .actionVuforia, .actionDeepLink, .actionBanner:
            return nil
        }
    }
}

//swiftlint:enable cyclomatic_complexity
