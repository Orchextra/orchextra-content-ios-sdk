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
    func displaySpinner(show: Bool)
}

class ArticlePresenter: NSObject, Refreshable {

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
            self.performButtonAction(info)
        } else if element is ElementRichText {
            self.performRichTextAction(info)
        }
    }
    // MARK: Helpers
    
    private func performButtonAction(_ info: Any) {
        // Perform button's action
        if let action = info as? String {
            self.actionInteractor.action(with: action) { action, _ in
                if action?.view() != nil, let unwrappedAction = action {
                    self.viewer?.showViewForAction(unwrappedAction)
                } else {
                    var actionUpdate = action
                    actionUpdate?.output = self
                    actionUpdate?.executable()
                }
            }
        }
    }
    
    private func performRichTextAction(_ info: Any) {
        // Open hyperlink's URL on web view
        if let URL = info as? URL {
            // Open on Safari VC
            OCM.shared.wireframe.showBrowser(url: URL)
        }
    }
    
    // MARK: - Refreshable
    
    func refresh() {
        self.viewer?.showLoadingIndicator()
        self.viewer?.update(with: self.article)
        self.viewer?.dismissLoadingIndicator()
    }
}

// MARK: - ActionOut

extension ArticlePresenter: ActionOut {
    
    func blockView() {
        self.viewer?.displaySpinner(show: true)
    }
    
    func unblockView() {
        self.viewer?.displaySpinner(show: false)
    }
}
