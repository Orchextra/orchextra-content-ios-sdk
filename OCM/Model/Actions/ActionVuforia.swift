//
//  ActionVuforia.swift
//  OCM
//
//  Created by Judith Medina on 3/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

struct ActionVuforia: Action {
    
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?

    init(preview: Preview?, shareInfo: ShareInfo?) {
        self.preview = preview
    } 
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionVuforia
            else { return nil }
        
        return ActionVuforia(preview: preview(from: json), shareInfo: shareInfo(from: json))
    }
    
    func view() -> UIViewController? {
        return nil
    }
    
    func executable() {
        OrchextraWrapper.shared.startVuforia()
    }
    
    func run(viewController: UIViewController?) {
        
        if let _ = preview, let fromVC = viewController {
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            self.executable()
        }
    }
}
