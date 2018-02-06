//
//  ActionWebview.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 26/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class ActionWebview: Action {
    
    var actionType: ActionType
    var customProperties: [String: Any]?
    var elementUrl: String?
    weak var output: ActionOutput?
    var url: URL
    var federated: [String: Any]?
    var identifier: String?
    var preview: Preview?
    var resetLocalStorage: Bool
    var requireAuth: String?
    internal var slug: String?
    internal var type: String?
    internal var shareInfo: ShareInfo?
    
    init(url: URL, federated: [String: Any]?, preview: Preview?, shareInfo: ShareInfo?, resetLocalStorage: Bool, slug: String?) {
        self.url = url
        self.federated = federated
        self.preview = preview
        self.shareInfo = shareInfo
        self.resetLocalStorage = resetLocalStorage
        self.slug = slug
        self.type = ActionTypeValue.webview
        self.actionType = .webview
    }
    
	static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionTypeValue.webview
        else { return nil }
        
        if let render = json["render"] {
            guard
                let urlString = render["url"]?.toString(),
                let url = self.findAndReplaceParameters(in: urlString)
            else {
                logWarn("Error parsing webview action")
                return nil
            }
            let slug = json["slug"]?.toString()
            let federated = render["federatedAuth"]?.toDictionary()
            return ActionWebview(
                url: url,
                federated: federated,
                preview: preview(from: json),
                shareInfo: shareInfo(from: json),
                resetLocalStorage: Config.resetLocalStorageWebView,
                slug: slug
            )
        }
        return nil
	}
    
    func updateLocalStorage() {
        if !OCM.shared.isLogged {
            self.resetLocalStorage = false
        }
    }
    
    private static func findAndReplaceParameters(in url: String) -> URL? {
        // Find each # parameter # in the url
        let parameters = Array(url.matchingStrings(regex: "#[0-9a-zA-Z-_]*#").joined())
        // Ask the delegate
        let values = OCM.shared.parameterCustomizationDelegate?.actionNeedsValues(for: parameters.map({ $0.replacingOccurrences(of: "#", with: "") }))
        var finalUrl = url
        // Replace each # parameter # with the given value
        values?.forEach { parameter, value in
            finalUrl = finalUrl.replacingOccurrences(of: "#\(parameter)#", with: value ?? "")
        }
        // It cleans the url of each # value #. Just if the integrating app didn't send the correct keys (for example, if u ask for "code" & "language" and the integrating app just send: ["code": "1234"]). This is a backup to avoid a bad-instanced URL.
        parameters.forEach { parameter in
            finalUrl = finalUrl.replacingOccurrences(of: "#\(parameter)#", with: "")
        }
        return URL(string: finalUrl) ?? URL(string: url)
    }
}
