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
    func showViewForAction(_ action: Action)
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
    
    func performAction(of element: Element, with info: String) {
        self.actionInteractor.action(with: info) { action, _ in
            if let unwrappedAction = action,
                action?.view() != nil {
                self.viewController?.showViewForAction(unwrappedAction)
            } else {
                action?.executable()
            }
        }
    }
}
