//
//  ActionCouponDetail.swift
//  OCM
//
//  Created by Alejandro Jiménez on 19/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ActionCouponDetail: Action {
	
	var idCoupon: String
	
	static func action(_ url: URLComponents) -> Action? {
		guard url.host == "coupons_campaign" else { return nil }
		
		let idCoupon = url.path.characters.dropFirst()
		return ActionCouponDetail(idCoupon: String(idCoupon))
	}
	
	func run() {
		OCM.shared.delegate?.openCoupon(self.idCoupon)
	}
	
}
