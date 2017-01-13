//
//  ActionBrowser.swift
//  OCM
//
//  Created by Judith Medina on 26/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ActionBrowser: Action {
    
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    
    let url: URL
    
    init(url: URL, preview: Preview?, shareInfo: ShareInfo?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionBrowser
            else { return nil }
        
        if let render = json["render"] {
            
            guard let urlString = render["url"]?.toString() else {
                print("URL render webview not valid.")
                return nil
            }
            guard let url = URL(string: urlString) else { return nil }
            return ActionBrowser(url: url, preview: preview(from: json), shareInfo: shareInfo(from: json))
        }
        return nil
    }
    
    func view() -> OrchextraViewController? {
        return nil
    }
    
    func executable() {
        _ = OCM.shared.wireframe.showBrowser(url: self.url)
    }
    
    func run(viewController: UIViewController?) {
        
        guard let fromVC = viewController else {
            return
        }
        
        if self.preview != nil {
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            OCM.shared.wireframe.showBrowser(url: self.url)
        }
    }
}
