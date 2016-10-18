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
	static func action(from json: JSON) -> Action?
	
	func view() -> UIViewController?
	func run()
}

// IMPLEMENTATION BY DEFAULT
extension Action {
	func view() -> UIViewController? {
		return nil
	}
}


class ActionFactory {
	
	class func action(from json: JSON) -> Action? {
		let actions = [
			ActionCoupons.action(from: json),
			ActionCouponDetail.action(from: json),
			ActionWebview.action(from: json),
			ActionContent.action(from: json),
			ActionArticle.action(from: json),
			ActionCustomScheme.action(from: json)
		]
		
		// Returns the last action that is not nil, or custom scheme is there is no actions
		return actions.reduce(ActionBanner.action(from: json)) { $1 ?? $0 }
	}
	
}
