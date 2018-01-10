//
//  ActionBanner.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 9/6/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


class ActionBanner: Action {
    
    var typeAction: ActionEnumType
    var requiredAuth: String? //!!!
    //var segmentation: [String: Any]? //!!!
    var elementUrl: String?
    var output: ActionOut?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    
    init(preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.preview = preview
        self.shareInfo = shareInfo
        self.slug = slug
        self.typeAction = ActionEnumType.actionBrowser
    }
    
	static func action(from json: JSON) -> Action? {
        let slug = json["slug"]?.toString()
        return ActionBanner(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
	}
}
