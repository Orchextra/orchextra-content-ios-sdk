//
//  ActionCustomScheme.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/7/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class ActionCustomScheme: Action {
    
    var typeAction: ActionEnumType
    var requiredAuth: String?
    var elementUrl: String?
    var output: ActionOut?
    let url: URLComponents
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    
    init(url: URLComponents, preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
        self.slug = slug
        self.type = ActionType.actionDeepLink
        self.typeAction = ActionEnumType.actionDeepLink
    }
	
	static func action(from json: JSON) -> Action? {
        guard let type = json["type"]?.toString() else { return nil }
        if type == ActionType.actionDeepLink {
            guard
                let uri = json["render.schemeUri"]?.toString(),
                let url = URLComponents(string: uri)
            else {
                return nil
            }
            let slug = json["slug"]?.toString()
            return ActionCustomScheme(
                url: url,
                preview: preview(from: json),
                shareInfo: shareInfo(from: json),
                slug: slug)
        }
        return nil
	}
}
