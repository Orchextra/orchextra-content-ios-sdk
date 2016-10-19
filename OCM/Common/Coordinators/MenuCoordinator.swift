//
//  MenuCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

typealias MenusResult = ([Menu]) -> Void

struct MenuCoordinator {
	
	let menuInteractor = MenuInteractor()
	
	func menus(completion: @escaping MenusResult) {
		let sessionInteractor = SessionInteractor(
			session: Session.shared,
			orchextra: OrchextraWrapper()
		)
		
		if sessionInteractor.hasSession() {
			self.loadMenus(completion: completion)
		} else {
			sessionInteractor.loadSession() { result in
				switch result {
				
				case .success( _):					
					self.loadMenus(completion: completion)
					
				case .error(let error):
					LogWarn(error)
				}
			}
		}
	}
	
	
	// MARK: - Private Helpers
	
	private func loadMenus(completion: @escaping MenusResult) {
		self.menuInteractor.loadMenus { result in
			switch result {
			case .success(let menus):
				completion(menus)
			
			case .empty:
				completion([])
				
			case .error(let message):
				LogInfo("ERROR: \(message)")
				completion([])
			}
		}
	}
	
}
