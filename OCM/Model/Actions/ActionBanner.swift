//
//  ActionBanner.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 9/6/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


struct ActionBanner: Action {
    
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?
    
    init(preview: Preview?, shareInfo: ShareInfo?) {
        self.preview = preview
        self.shareInfo = shareInfo
    }
    
	static func action(from json: JSON) -> Action? {
        return ActionBanner(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json)
        )
	}
	
	func executable() {
		// DO NOTHING
		logInfo("Do nothing action...")
	}
	
	func run(viewController: UIViewController?) {
        if self.preview != nil {
            guard let fromVC = viewController else {
                return
            }
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        }
	}
	
}
