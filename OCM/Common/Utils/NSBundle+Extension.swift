//
//  NSBundle+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


extension NSBundle {
	
	class func OCM() -> NSBundle {
		guard let bundle = NSBundle(identifier: "com.orchextra.ocm") else {
			LogWarn("OCM bundle not found")
			return NSBundle.mainBundle()
		}
		
		return bundle
	}
	
}
