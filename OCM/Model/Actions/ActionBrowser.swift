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
        self.type = ActionType.actionBrowser
        self.typeAction = ActionEnumType.actionBrowser
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionBrowser
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
    
    func view() -> OrchextraViewController? {// TODO EDU quitar
        return self.actionView
    }
    
    func executable() { // TODO EDU quitar
        self.launchShowBrowser(viewController: nil)
    }
    
    func run(viewController: UIViewController?) { // TODO EDU quitar
        self.launchShowBrowser(viewController: viewController)
    }
    
    // MARK: Private Method
    
    private func launchShowBrowser(viewController: UIViewController?) {
        if OCM.shared.isLogged {
            if let federatedData = self.federated, federatedData["active"] as? Bool == true {
                self.output?.blockView()
                OCM.shared.delegate?.federatedAuthentication(federatedData, completion: { params in
                    self.output?.unblockView()
                    
                    var urlFederated = self.url.absoluteString
                    
                    guard let params = params else {
                        logWarn("ActionBrowser: urlFederatedAuth params is null")
                        self.launchAction(viewController: viewController)
                        return
                    }
                    
                    for (key, value) in params {
                        urlFederated = self.concatURL(url: urlFederated, key: key, value: value)
                    }
                    
                    guard let urlFederatedAuth = URL(string: urlFederated) else {
                        logWarn("ActionBrowser: urlFederatedAuth is not a valid URL")
                        self.launchAction(viewController: viewController)
                        return
                        
                    }
                    self.url = urlFederatedAuth
                    logInfo("ActionBrowser: received urlFederatedAuth: \(self.url)")
                    
                    self.launchAction(viewController: viewController)
                })
            } else {
                logInfo("ActionBrowser: open: \(self.url)")
                self.launchAction(viewController: viewController)
            }
        } else {
            self.launchAction(viewController: viewController)
        }
    }
    
    private func launchAction(viewController: UIViewController?) { // TODO EDU quitar
        if self.preview != nil {
            guard let fromVC = viewController else {
                OCM.shared.wireframe.showBrowser(url: self.url)
                return
            }
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            OCM.shared.wireframe.showBrowser(url: self.url)
        }
    }
    
    private func concatURL(url: String, key: String, value: Any) -> String { // TODO EDU quitar
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
