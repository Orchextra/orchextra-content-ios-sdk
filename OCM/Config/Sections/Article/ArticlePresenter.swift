//
//  ArticlePresenter.swift
//  OCM
//
//  Created by Judith Medina on 19/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol PArticleVC: class {
    func show(article: Article)
    func show(actionView: OrchextraViewController)
}

class ArticlePresenter: NSObject {
    
    let article: Article
    weak var viewController: PArticleVC?
    let actionInteractor: ActionInteractor
    
    init(article: Article, actionInteractor: ActionInteractor) {
        self.article = article
        self.actionInteractor = actionInteractor
    }
    
    func viewIsReady() {
        self.viewController?.show(article: self.article)
    }
    
    func performAction(of element: Element, with info: Any) {
        
        if element is ElementButton {
            // Perform button's action
            if let action = info as? String {
                self.actionInteractor.action(with: action) { action, _ in
                    if let view = action?.view() {
                        self.viewController?.show(actionView: view)
                    } else {
                        action?.executable()
                    }
                }
            }
        } else if element is ElementRichText {
            // Open hyperlink's URL on web view
            if let URL = info as? URL {
                // Open on Safari VC
                OCM.shared.wireframe.showBrowser(url: URL)
                // Open in WebView VC
                // TODO: Define how the URL should me shown
                // if let webVC = OCM.shared.wireframe.showWebView(url: URL) {
                //    OCM.shared.wireframe.show(viewController: webVC)
                // }
            }
        }
        
    }
}
