//
//  Action.swift
//  OCM
//
//  Created by Alejandro Jiménez on 19/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


protocol Action {
    
	static func action(_ url: URLComponents) -> Action?
	func run()
    
}


class ActionFactory {
	
	class func action(_ json: JSON?) -> Action? {
		guard
			let jsonAction = json,
			let url = urlComponents(jsonAction)
			else { return nil }
		
		let actions = [
			ActionCoupons.action(url),
			ActionCouponDetail.action(url),
			ActionWebview.action(url),
			ActionBanner.action(url)
		]
		
		// Returns the last action that is not nil, or custom scheme is there is no actions
		return actions.reduce(ActionCustomScheme.action(url)) { $1 ?? $0 }
	}
	
	fileprivate class func urlComponents(_ json: JSON) -> URLComponents? {
		guard let link = json["link"]?.toString()
			else { LogWarn("link field not found in action json"); return nil }
		
		let url = URLComponents(string: link)
		
		return url
	}
	
}
