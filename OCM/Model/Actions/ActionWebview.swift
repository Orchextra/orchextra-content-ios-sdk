//
//  ActionWebview.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 26/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct ActionWebview: Action {
    
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
        guard json["type"]?.toString() == ActionType.actionWebview
        else { return nil }
        
        if let render = json["render"] {
            
            guard let urlString = render["url"]?.toString() else {
                    logError(NSError(message: "URL render webview not valid."))
                    return nil
            }
            guard let url = URL(string: urlString) else { return nil }
            return ActionWebview(url: url, preview: preview(from: json), shareInfo: shareInfo(from: json))
        }
        return nil
	}
    
    func view() -> OrchextraViewController? {
        return OCM.shared.wireframe.showWebView(url: self.url)
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
