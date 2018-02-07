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
        self.shareInfo = shareInfo
        self.slug = slug
        self.type = ActionTypeValue.scan
        self.actionType = .scan
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionTypeValue.scan
            else { return nil }
        let slug = json["slug"]?.toString()
        return ActionScanner(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
    }
}
