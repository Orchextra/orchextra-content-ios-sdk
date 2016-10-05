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
	
	class func action(from url: URLComponents) -> Action? {
		let actions = [
			ActionCoupons.action(url),
			ActionCouponDetail.action(url),
			ActionWebview.action(url),
			ActionBanner.action(url),
			ActionContent.action(url)
		]
		
		// Returns the last action that is not nil, or custom scheme is there is no actions
		return actions.reduce(ActionCustomScheme.action(url)) { $1 ?? $0 }
	}
	
	class func action(from string: String) -> Action? {
		return URLComponents(string: string).flatMap(self.action)
	}
	
	class func action(from json: JSON) -> Action? {
		return json["actionUri"]?.toString().flatMap(URLComponents.init).flatMap(self.action)
	}
	
}
