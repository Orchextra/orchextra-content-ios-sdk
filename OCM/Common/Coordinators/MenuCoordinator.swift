//
//  MenuCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

typealias MenusResult = (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void

struct MenuCoordinator {
	
	let menuInteractor = MenuInteractor()
    let sessionInteractor: SessionInteractorProtocol
	
	func menus(completion: @escaping MenusResult) {
		if sessionInteractor.hasSession() {
			self.loadMenus(completion: completion)
		} else {
			sessionInteractor.loadSession { result in
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
                completion(true, menus, nil)
			
			case .empty:
				completion(true, [], nil)
				
			case .error(let message):
				LogInfo("ERROR: \(message)")
				completion(false, [], NSError.OCMError(message: nil, debugMessage: kLocaleOcmErrorContent, baseError: nil))
			}
		}
	}
	
}
