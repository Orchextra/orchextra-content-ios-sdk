//
//  ActionScanner.swift
//  OCM
//
//  Created by Judith Medina on 28/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ActionScanner: Action {
    
    var output: ActionOut?
    internal var slug: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?

    init(preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.preview = preview
        self.shareInfo = shareInfo
        self.slug = slug
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionScan
            else { return nil }
        let slug = json["slug"]?.toString()
        return ActionScanner(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
    }
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
    
    func executable() {
        OrchextraWrapper.shared.startScanner()
    }
    
    func run(viewController: UIViewController?) {
        
        if self.preview != nil, let fromVC = viewController {
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            self.executable()
        }
    }
}
