//
//  ActionInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ActionInteractor {
	
	let dataManager: ActionDataManager
	
	func action(from url: String) -> Action? {
		do {
			let action = try self.dataManager.cachedAction(from: url)
			return action
			
		} catch let error {
			if let error = error as? ActionError {
				error.logError()
			}
			return nil
		}
	}
	
}
