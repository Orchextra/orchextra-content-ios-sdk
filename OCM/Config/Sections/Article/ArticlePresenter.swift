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
    func update(with article: Article)
    func showViewForAction(_ action: Action)
    func showLoadingIndicator()
    func dismissLoadingIndicator()
}

class ArticlePresenter: NSObject {

    let article: Article
    weak var viewer: PArticleVC?
    let actionInteractor: ActionInteractor
    let refreshManager = RefreshManager.shared
    var loaded = false
    var viewDataStatus: ViewDataStatus = .canReload
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    init(article: Article, actionInteractor: ActionInteractor, reachability: ReachabilityWrapper) {
        self.article = article
        self.actionInteractor = actionInteractor
    }
    
    func viewDidLoad() {
        self.refreshManager.registerForNetworkChanges(self)
    }
    
    func viewWillAppear() {
        if !self.loaded {
            self.loaded = true
            self.viewer?.show(article: self.article)
        } else {
            self.viewer?.update(with: self.article)
        }
    }
    
    func performAction(of element: Element, with info: Any) {
        
        if element is ElementButton {
            // Perform button's action
            if let action = info as? String {
                self.actionInteractor.action(with: action) { action, _ in
                    if action?.view() != nil, let unwrappedAction = action {
                        self.viewer?.showViewForAction(unwrappedAction)
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


// MARK: - Refreshable

extension ArticlePresenter: Refreshable {
    
    func refresh() {
        self.viewer?.showLoadingIndicator()
        self.viewer?.update(with: self.article)
        self.viewer?.dismissLoadingIndicator()
    }   
}
