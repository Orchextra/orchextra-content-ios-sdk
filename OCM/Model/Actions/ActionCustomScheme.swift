//
//  ActionCustomScheme.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/7/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ActionCustomScheme: Action {
	
	let url: URLComponents
	
	static func action(_ url: URLComponents) -> Action? {
		return ActionCustomScheme(url: url)
	}
	
	func run() {
		OCM.shared.delegate?.customScheme(self.url)
	}
	
}
