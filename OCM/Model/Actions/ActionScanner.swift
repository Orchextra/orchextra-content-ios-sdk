//
//  ActionScanner.swift
//  OCM
//
//  Created by Judith Medina on 28/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ActionScanner: Action {
    
    var typeAction: ActionEnumType
    var customProperties: [String: Any]? //!!!
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
        self.type = ActionType.actionScan
        self.typeAction = ActionEnumType.actionScan
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionScan
            else { return nil }
        let slug = json["slug"]?.toString()
        return ActionScanner(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
    }
}
