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
    
    var elementUrl: String?
    var output: ActionOut?
    var url: URL
    var federated: [String: Any]?
    var identifier: String?
    var preview: Preview?
    var resetLocalStorage: Bool
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
        self.type = ActionType.actionWebview
    }
    
	static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionWebview
        else { return nil }
        
        if let render = json["render"] {
            
            guard let urlString = render["url"]?.toString() else {
                    logError(NSError(message: "URL render webview not valid."))
                    return nil
            }
            guard let url = URL(string: urlString) else { return nil }
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
    
    func view() -> OrchextraViewController? {
        return self.actionView()
    }
    
    func actionView() -> OrchextraViewController? {
        let action = self
        self.resetLocalStorage = false
        return OCM.shared.wireframe.loadWebView(with: action)
    }
    
    func executable() {
        guard let viewController = self.view() else { return }
        OCM.shared.wireframe.show(viewController: viewController)
    }
	
    func run(viewController: UIViewController?) {
        
        guard let fromVC = viewController else {
            return
        }
        
        OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
	}
}
