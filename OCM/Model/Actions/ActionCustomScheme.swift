//
//  ActionCustomScheme.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/7/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ActionCustomScheme: Action {
    
    internal var id: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    internal var actionView: OrchextraViewController?

	let url: URLComponents
    
    init(url: URLComponents, preview: Preview?, shareInfo: ShareInfo?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
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
            return ActionCustomScheme(url: url, preview: preview(from: json), shareInfo: shareInfo(from: json))
        }
        return nil
	}
	
	func executable() {
		OCM.shared.delegate?.customScheme(self.url)
	}
	
    func run(viewController: UIViewController?) {
		guard let fromVC = viewController else {
			return
		}
		
		OCM.shared.wireframe.showMainComponent(with: self, viewController: fromVC)
	}
	
}
