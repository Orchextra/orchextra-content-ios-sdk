//
//  ActionBanner.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 9/6/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary


struct ActionBanner: Action {
    internal var preview: Preview?

	
	static func action(from json: JSON) -> Action? {
		return ActionBanner()
	}

    func run(viewController: UIViewController?) {
		// DO NOTHING
		LogInfo("Do nothing action...")
	}
	
}
