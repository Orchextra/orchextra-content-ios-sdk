//
//  OpenContentCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/8/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ContentInteractor {
	
	let storage: Storage
	
	func openContent(_ contentId: String) {
		guard let contentList = self.storage.contentList else { return LogWarn("No contents loaded yet") }
		guard let content = (contentList.filter { $0.id == contentId }.first) else { return LogWarn("Content not found") }
		
		content.action?.run()
	}
	
}
