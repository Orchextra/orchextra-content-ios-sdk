//
//  ActionExternalBrowser.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 05/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ActionExternalBrowser: Action {
    
    var typeAction: ActionEnumType
    var elementUrl: String?
    var output: ActionOut?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?
    internal var federated: [String: Any]?
    
    var url: URL
    
    init(url: URL, preview: Preview?, shareInfo: ShareInfo?, federated: [String: Any]?, slug: String?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
        self.federated = federated
        self.slug = slug
        self.type = ActionType.actionExternalBrowser
        self.typeAction = ActionEnumType.actionExternalBrowser
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionExternalBrowser
            else { return nil }
        
        if let render = json["render"] {
            
            guard let urlString = render["url"]?.toString() else {
                logError(NSError(message: "URL render webview not valid."))
                return nil
            }
            guard let url = URL(string: urlString) else { return nil }
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
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
    
    func executable() {
        self.launchOpenUrl()
    }
    
    func run(viewController: UIViewController?) {
        self.launchOpenUrl()
    }
    
    // MARK: Private Method
    
    private func launchOpenUrl() {
        if OCM.shared.isLogged {
            if let federatedData = self.federated, federatedData["active"] as? Bool == true {
                self.output?.blockView()
                OCM.shared.delegate?.federatedAuthentication(federatedData, completion: { params in
                    
                    self.output?.unblockView()
                    
                    var urlFederated = self.url.absoluteString
                    
                    guard let params = params else {
                        logWarn("ActionExternalBrowser: urlFederatedAuth params is null")
                        UIApplication.shared.openURL(self.url)
                        return
                    }
                    
                    for (key, value) in params {
                        urlFederated = self.concatURL(url: urlFederated, key: key, value: value)
                    }
                    
                    guard let urlFederatedAuth = URL(string: urlFederated) else {
                        logWarn("ActionExternalBrowser: urlFederatedAuth is not a valid URL")
                        UIApplication.shared.openURL(self.url)
                        return
                        
                    }
                    self.url = urlFederatedAuth
                    logInfo("ActionExternalBrowser: received urlFederatedAuth: \(self.url)")
                    
                    UIApplication.shared.openURL(self.url)
                })
            } else {
                logInfo("ActionExternalBrowser: open: \(self.url)")
                UIApplication.shared.openURL(self.url)
            }
        } else {
            UIApplication.shared.openURL(self.url)
        }
    }
    
    private func concatURL(url: String, key: String, value: Any) -> String {
        guard let valueURL = value as? String else {
            LogWarn("Value URL is not a String")
            return url
        }
        
        var urlResult = url
        if url.contains("?") {
            urlResult = "\(url)&\(key)=\(valueURL)"
        } else {
            urlResult = "\(url)?\(key)=\(valueURL)"
        }
        return urlResult
    }
}
