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
  
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?

	let url: URLComponents
    
    init(url: URLComponents, preview: Preview?, shareInfo: ShareInfo?) {
        self.url = url
        self.preview = preview
        self.shareInfo = shareInfo
    }
	
	static func action(from json: JSON) -> Action? {
        guard json["type"]?.toString() == ActionType.actionDeepLink
            else { return nil }
        
        guard let uri = json["render.uri"]?.toString(),
            let url = URLComponents(string: uri) else { return nil }
        
        return ActionCustomScheme(url: url, preview: preview(from: json), shareInfo: shareInfo(from: json))
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
