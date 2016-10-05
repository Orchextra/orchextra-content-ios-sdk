//
//  ActionContent.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

struct ActionContent: Action {
	
	let slug: String
	
	static func action(_ url: URLComponents) -> Action? {
		guard url.host == "content" else { return nil }
		let slug = url.path.characters.dropFirst()
		
		return ActionContent(slug: String(slug))
	}
	
	func run() {
		
	}
	
}
