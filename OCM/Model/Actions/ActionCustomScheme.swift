//
//  ActionCustomScheme.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/7/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ActionCustomScheme: Action {
	
	let url: NSURLComponents
	
	static func action(url: NSURLComponents) -> Action? {
		return ActionCustomScheme(url: url)
	}
	
	func run() {
		OCM.shared.delegate?.customScheme(self.url)
	}
	
}
