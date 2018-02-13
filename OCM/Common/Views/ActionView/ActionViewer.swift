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
    var ocmController: OCMController
    
    func view() -> OrchextraViewController? {
        switch self.action.actionType {
        case .article:
            guard let actionArticle = self.action as? ActionArticle else { logWarn("Action doesn't is a ActionArticle"); return nil }
            return self.ocmController.wireframe?.loadArticle(
                with: actionArticle.article,
                elementUrl: self.action.elementUrl
            )
            
        case .webview:
            guard let actionWebview = self.action as? ActionWebview else { logWarn("Action doesn't is a ActionWebview"); return nil }
            return self.ocmController.wireframe?.loadWebView(with: actionWebview)
            
        case .card:
            guard let action =  action as? ActionCard else { logWarn("action doesn't is a ActionCard"); return nil }
            return self.ocmController.wireframe?.loadCards(with: action.cards)
            
        case .content:
            guard let actionContent = self.action as? ActionContent else { logWarn("Action doesn't is a ActionContent"); return nil }
            return self.ocmController.wireframe?.loadContentList(from: actionContent.path)
            
        case .video:
            guard let action =  action as? ActionVideo else { logWarn("action doesn't is a ActionVideo"); return nil }
            
            switch action.video.format {
            case .youtube:
                return self.ocmController.wireframe?.loadYoutubeVC(with: action.video.source)
            default:
                return self.ocmController.wireframe?.loadVideoPlayerVC(with: action.video)
            }
            
        case .externalBrowser, .browser, .scan, .deepLink, .banner:
            return nil
        }
    }
    
    func mainContentComponentUI() -> MainContentComponentUI? {
        if let content = self.view() as? MainContentComponentUI {
            return content
        } else {
            return nil
        }
    }
}

//swiftlint:enable cyclomatic_complexity
