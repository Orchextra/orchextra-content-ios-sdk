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
	
    /// Method to get an action asynchronously
    ///
    /// - Parameters:
    ///   - url: The url of the action
    ///   - completion: Block to return the action
    func action(with id: String, completion: @escaping (Action?, Error?) -> Void) {
        self.dataManager.cachedOrAPIAction(with: id, completion: { action, error in
            completion(action, error)
        })
    }
    
}
