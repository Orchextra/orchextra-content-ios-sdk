//
//  ActionContent.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct ActionContent: Action {
	
	let path: String
	
	static func action(from json: JSON) -> Action? {
		guard json["type"]?.toString() == ActionType.ActionContent,
		let path = json["render.contentUrl"]?.toString()
		else { return nil }
		
		return ActionContent(path: path)
	}
	
	func view() -> UIViewController? {
		return OCM.shared.wireframe.contentList(from: path)
	}
	
	func run() {
		
	}
	
}
