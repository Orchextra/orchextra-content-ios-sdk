//
//  ActionCustomScheme.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/7/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class ActionCustomScheme: Action {
    
    var typeAction: ActionEnumType
    var elementUrl: String?
    var output: ActionOut?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?

	let url: URLComponents
    
    init(url: URLComponents, preview: Preview?, shareInfo: ShareInfo?, slug: String?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
        self.slug = slug
        self.type = ActionType.actionDeepLink
        self.typeAction = ActionEnumType.actionDeepLink
    }
	
	static func action(from json: JSON) -> Action? {
        guard let type = json["type"]?.toString() else { return nil }
        if type == ActionType.actionDeepLink {
            guard
                let uri = json["render.schemeUri"]?.toString(),
                let url = URLComponents(string: uri)
            else {
                return nil
            }
            let slug = json["slug"]?.toString()
            return ActionCustomScheme(
                url: url,
                preview: preview(from: json),
                shareInfo: shareInfo(from: json),
                slug: slug)
        }
        return nil
	}
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
	
	func executable() {
		OCM.shared.delegate?.customScheme(self.url)
	}
	
    func run(viewController: UIViewController?) {
        if self.preview != nil {
            guard let fromVC = viewController else {
                return
            }
            OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
        } else {
            executable()
        }
	}
}
