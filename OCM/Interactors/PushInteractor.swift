//
//  PushInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/5/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct PushInteractor {
	
	func pushReceived(notification: AnyObject) {
		LogInfo("Notification receiver: \(notification)")
		let jsonAction = JSON(json: notification)["action"]
		
		guard let actionValueString = jsonAction?.toString() else { return LogWarn("Action value is not an sctring") }
		guard let actionValueData = actionValueString.dataUsingEncoding(NSUTF8StringEncoding) else {return LogWarn("Error while encoding string") }
		guard let actionValueJson = try? JSON.dataToJson(actionValueData) else { return LogWarn("Error converting data to json") }
		
		LogInfo("\(actionValueJson)")
		
		let action2 = ActionFactory.action(actionValueJson)
		
		action2?.run()
	}
	
}
