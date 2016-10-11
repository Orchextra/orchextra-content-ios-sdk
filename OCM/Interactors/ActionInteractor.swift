//
//  ActionInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ActionInteractor {
	
	func action(from url: String) -> Action {
		return ActionFactory.action(from: url)!
	}
	
}
