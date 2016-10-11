//
//  ActionBanner.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 9/6/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit


struct ActionBanner: Action {
	
	static func action(_ url: URLComponents) -> Action? {
		guard url.host == "do_nothing" else { return nil }
		
		return ActionBanner()
	}

	func run() {
		// DO NOTHING
		LogInfo("Do nothing action...")
	}
	
}
