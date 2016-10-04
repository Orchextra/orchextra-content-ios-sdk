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
	
	let url: URL
	
	static func action(_ url: URLComponents) -> Action? {
		guard
			url.scheme == "http" || url.scheme == "https",
			let urlString = url.url
			else { return nil }
		
		return ActionWebview(url: urlString)
	}
	
	func run() {
		let wireframe = Wireframe(
			application: Application()
		)
		wireframe.showWebView(self.url)
	}
}
