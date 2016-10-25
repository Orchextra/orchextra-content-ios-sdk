//
//  NSBundle+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


extension Bundle {

	class func OCMBundle() -> Bundle {
		return Bundle(for: OCM.self)
	}

}
