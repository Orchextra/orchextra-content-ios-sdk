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
    
//    func view() -> UIViewController? {
////        return OCM.shared.wireframe.contentList(from: path)
//    }
    
    func run() {
        
        let wireframe = Wireframe(
            application: Application()
        )
        wireframe.showArticle(article)
    }
}
