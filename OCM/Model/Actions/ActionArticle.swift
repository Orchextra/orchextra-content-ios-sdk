//
//  ActionArticle.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//


import UIKit
import GIGLibrary

class ActionArticle: Action {
    
    var typeAction: ActionEnumType
    var requiredAuth: String?
    var elementUrl: String?
    var output: ActionOut?
    let article: Article
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    
    init(article: Article, preview: Preview?, shareInfo: ShareInfo? = nil, slug: String?) {
        self.article = article
        self.preview = preview
        self.shareInfo = shareInfo
        self.slug = slug
        self.type = ActionType.actionArticle
        self.typeAction = ActionEnumType.actionArticle
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionArticle,
            let article = Article.article(from: json, preview: preview(from: json))
            else { return nil }
        let slug = json["slug"]?.toString()
        return ActionArticle(
            article: article,
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
    }
}
