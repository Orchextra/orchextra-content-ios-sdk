//
//  ActionCard.swift
//  OCM
//
//  Created by Carlos Vicente on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ActionCard: Action {
    
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionCard,
            let article = Article.article(from: json, preview: preview(from: json))
            else { return nil }
        return ActionArticle(
            article: article,
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            actionView: OCM.shared.wireframe.showArticle(article)
        
//        return ActionCard(
//            preview: preview(from: json),
//            shareInfo: shareInfo(from: json),
//            actionView: OCM.shared.wireframe.showArticle(article)

        )
    }


}
