//
//  ActionVuforia.swift
//  OCM
//
//  Created by Judith Medina on 3/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ActionVuforia: Action {
    
    var typeAction: ActionEnumType
    var elementUrl: String?
    var output: ActionOut?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController? // TODO EDU borrar

    init(preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.preview = preview
        self.slug = slug
        self.type = ActionType.actionVuforia
        self.typeAction = ActionEnumType.actionVuforia
    }
    
    func view() -> OrchextraViewController? { // TODO EDU borrar
        return self.actionView
    }
    
    static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionVuforia
            else { return nil }
        let slug = json["slug"]?.toString()
        return ActionVuforia(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            slug: slug
        )
    }
    
    func executable() { // TODO EDU borrar
        OrchextraWrapper.shared.startVuforia()
    }
    
    func run(viewController: UIViewController?) { // TODO EDU borrar        
        if self.preview != nil, let fromVC = viewController {
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            self.executable()
        }
    }
}
