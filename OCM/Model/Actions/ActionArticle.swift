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

    init(article: Article, preview: Preview?) {
        self.article = article
        self.preview = preview
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionArticle,
            let article = Article.parseArticle(from: json)
            else { return nil }
        
        return ActionArticle(article: article, preview: preview(from: json))
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
