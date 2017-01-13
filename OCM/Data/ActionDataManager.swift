//
//  ActionDataManager.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


enum ActionError: Error {
	case notInCache
	case cacheNotInitialized
	case jsonError
	
	func logError(filename: NSString = #file, line: Int = #line, funcname: String = #function) {
		var string: String
		
		switch self {
		case .notInCache:
			string = "Action not in cache"
			
		case .cacheNotInitialized:
			string = "Cache not initialized"
			
		case .jsonError:
			string = "Error parsing json action"
		}
		
		LogWarn(string, filename: filename, line: line, funcname: funcname)
	}
}

struct ActionDataManager {
	
	let storage: Storage
	
	func cachedAction(from url: String) throws -> Action {
		guard let json = self.storage.elementsCache else { throw ActionError.cacheNotInitialized }
		guard let jsonAction = json[url] else { throw ActionError.notInCache }
		guard var action = ActionFactory.action(from: jsonAction) else { throw ActionError.jsonError }
        action.id = url
		return action
	}
}
