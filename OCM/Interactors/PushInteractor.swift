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
	
	func pushReceived(_ notification: [AnyHashable : Any]) {
		logInfo("Notification receiver: \(notification)")
		let jsonAction = JSON(from: notification)["action"]

		guard let actionValueString = jsonAction?.toString() else { return logWarn("Action value is not an sctring") }
		guard let actionValueData = actionValueString.data(using: String.Encoding.utf8) else {return logWarn("Error while encoding string") }
		guard let actionValueJson = try? JSON.dataToJson(actionValueData) else { return logWarn("Error converting data to json") }
		
		logInfo("\(actionValueJson)")
		
		let action2 = ActionFactory.action(from: actionValueJson)
		
		action2?.run()
	}
	
}
