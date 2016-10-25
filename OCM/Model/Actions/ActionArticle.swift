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
    
    init(article: Article) {
       self.article = article
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionArticle,
            let article = Article.parseArticle(from: json)
            else { return nil }
        
        return ActionArticle(article: article)
    }
    
    func view() -> UIViewController? {
        
        return OCM.shared.wireframe.showArticle(self.article)
    }
    
    func run(viewController: UIViewController?) {
        
        let wireframe = Wireframe(
            application: Application()
        )
        
        guard let fromVC = viewController else {
            return
        }
        wireframe.showMainComponent(with: self.article, action: self, viewController: fromVC)
    }
}
