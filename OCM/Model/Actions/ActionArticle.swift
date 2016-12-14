//
//  ActionArticle.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//


import UIKit
import GIGLibrary

struct ActionArticle: Action {
    
    let article: Article
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?

    init(article: Article, preview: Preview?, shareInfo: ShareInfo? = nil) {
        self.article = article
        self.preview = preview
        self.shareInfo = shareInfo
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionArticle,
            let article = Article.article(from: json, preview: preview(from: json))
            else { return nil }
        return ActionArticle(article: article, preview: preview(from: json), shareInfo: shareInfo(from: json))
    }
    
    func view() -> OrchextraViewController? {
        
        return OCM.shared.wireframe.showArticle(self.article)
    }
    
    func run(viewController: UIViewController?) {

        guard let fromVC = viewController else {
            return
        }
        
        OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
    }
}
