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
    
	static func action(url: NSURLComponents) -> Action?
	func run()
    
}


class ActionFactory {
	
	class func action(json: JSON?) -> Action? {
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
	
	private class func urlComponents(json: JSON) -> NSURLComponents? {
		guard let link = json["link"]?.toString()
			else { LogWarn("link field not found in action json"); return nil }
		
		let url = NSURLComponents(string: link)
		
		return url
	}
	
}
