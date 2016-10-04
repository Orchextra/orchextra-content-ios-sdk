//
//  OpenWidgetCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/8/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct WidgetInteractor {
	
	let storage: Storage
	
	func openWidget(widgetId: String) {
		guard let widgetList = self.storage.widgetList else { return LogWarn("No widgets loaded yet") }
		guard let widget = (widgetList.filter { $0.id == widgetId }.first) else { return LogWarn("Widget not found") }
		
		widget.action?.run()
	}
	
}
