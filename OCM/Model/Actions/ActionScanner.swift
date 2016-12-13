//
//  ActionScanner.swift
//  OCM
//
//  Created by Judith Medina on 28/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ActionScanner: Action {

    internal var preview: Preview?
    internal var shareUrl: String?

    init(preview: Preview?, shareUrl: String?) {
        self.preview = preview
        self.shareUrl = shareUrl
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionScan
            else { return nil }
        
        return ActionScanner(preview: preview(from: json), shareUrl: shareUrl(from: json))
    }
    
    func view() -> UIViewController? {
        return nil
    }
    
    func executable() {
        OrchextraWrapper().startScanner()
    }
    
    func run(viewController: UIViewController?) {
        
        if let _ = preview, let fromVC = viewController {
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            self.executable()
        }
    }
}
