//
//  ActionVuforia.swift
//  OCM
//
//  Created by Judith Medina on 3/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ActionVuforia: Action {
    
    var actionType: ActionType
    var customProperties: [String: Any]?
    var elementUrl: String?
    weak var output: ActionOutput?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?

    init(preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.preview = preview
        self.slug = slug
        self.type = ActionTypeValue.vuforia
        self.actionType = .vuforia
    }

    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionTypeValue.vuforia
            else { return nil }
        let slug = json["slug"]?.toString()
        return ActionVuforia(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
    }
}
