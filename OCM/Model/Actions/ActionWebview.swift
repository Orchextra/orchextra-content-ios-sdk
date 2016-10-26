//
//  ActionWebview.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 26/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct ActionWebview: Action {
    
    internal var preview: Preview?
	
	let url: URL
	
	static func action(from json: JSON) -> Action? {
		return nil
	}
	
	func run() {
		let wireframe = Wireframe(
			application: Application()
		)
		wireframe.showWebView(self.url)
	}
}
