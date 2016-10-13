//
//  NSBundle+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


extension Bundle {

	class func OCM() -> Bundle {
		guard let bundle = Bundle(identifier: "com.orchextra.ocm") else {
			LogWarn("OCM bundle not found")
			return Bundle.main
		}

		return bundle
	}

}
