//
//  ActionExternalBrowser.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 05/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ActionExternalBrowser: Action {
    
    internal var identifier: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?
    
    let url: URL
    
    init(url: URL, preview: Preview?, shareInfo: ShareInfo?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
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
            return ActionExternalBrowser(url: url, preview: preview(from: json), shareInfo: shareInfo(from: json))
        }
        return nil
    }
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
    
    func executable() {
        
        UIApplication.shared.openURL(url)
    }
    
    func run(viewController: UIViewController?) {

        UIApplication.shared.openURL(url)
    }
}
