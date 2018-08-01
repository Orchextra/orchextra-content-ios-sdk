//
//  ActionExternalBrowser.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 05/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ActionExternalBrowser: Action, FederableAction, CustomizableActionURL {
    
    var actionType: ActionType
    weak var federateDelegate: FederableActionDelegate?
    var customProperties: [String: Any]?
    var elementUrl: String?
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
        self.type = ActionTypeValue.externalBrowser
        self.actionType = .externalBrowser
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionTypeValue.externalBrowser
            else { return nil }
        
        if let render = json["render"] {
            
            guard let urlString = render["url"]?.toString() else {
                LogError(NSError(message: "URL render webview not valid."))
                return nil
            }
            guard let url = self.findAndReplaceParameters(in: urlString) else { return nil }
            let slug = json["slug"]?.toString()
            let federated = render["federatedAuth"]?.toDictionary()
            return ActionExternalBrowser(
                url: url,
                preview: preview(from: json),
                shareInfo: shareInfo(from: json),
                federated: federated,
                slug: slug)
        }
        return nil
    }
}
