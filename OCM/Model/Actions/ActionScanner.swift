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
    internal var identifier: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?

    init(preview: Preview?, shareInfo: ShareInfo?) {
        self.preview = preview
        self.shareInfo = shareInfo
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionScan
            else { return nil }
        
        return ActionScanner(preview: preview(from: json), shareInfo: shareInfo(from: json))
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
