//
//  ActionCoupons.swift
//  OCM
//
//  Created by Alejandro Jiménez on 19/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

struct ActionCoupons: Action {
	
	static func action(_ url: URLComponents) -> Action? {
		guard url.host == "coupons" else { return nil }
		
		return ActionCoupons()
	}
	
	func run() {
		OCM.shared.delegate?.openCoupons()
	}
	
}
