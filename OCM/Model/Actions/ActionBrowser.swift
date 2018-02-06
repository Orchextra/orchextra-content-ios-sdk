//
//  ActionBrowser.swift
//  OCM
//
//  Created by Judith Medina on 26/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


class ActionBrowser: Action {
    
    var actionType: ActionType
    var customProperties: [String: Any]?
    var elementUrl: String?
    weak var output: ActionOutput?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var federated: [String: Any]?
    
    var url: URL
    
    init(url: URL, preview: Preview?, shareInfo: ShareInfo?, federated: [String: Any]?, slug: String?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
        self.federated = federated
        self.slug = slug
        self.type = ActionTypeValue.browser
        self.actionType = .browser
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionTypeValue.browser
            else { return nil }
        
        if let render = json["render"] {
            
            guard let urlString = render["url"]?.toString() else {
                logError(NSError(message: "URL render webview not valid."))
                return nil
            }
            guard let url = URL(string: urlString) else { return nil }
            let slug = json["slug"]?.toString()
            let federated = render["federatedAuth"]?.toDictionary()
            return ActionBrowser(
                url: url,
                preview: preview(from: json),
                shareInfo: shareInfo(from: json),
                federated: federated,
                slug: slug)
        }
        return nil
    }
}
