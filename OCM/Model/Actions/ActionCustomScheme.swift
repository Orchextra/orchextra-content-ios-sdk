//
//  ActionCustomScheme.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/7/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ActionCustomScheme: Action {
	
	let url: URLComponents
	
	static func action(from json: JSON) -> Action? {
		return nil
	}
	
	func run() {
		OCM.shared.delegate?.customScheme(self.url)
	}
	
}
