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
    
    let sessionInteractor: SessionInteractorProtocol
    let menuInteractor: MenuInteractor
    
	func menus(completion: @escaping MenusResult) {
        if self.sessionInteractor.hasSession() {
            self.loadMenus(completion: completion)
        } else {
            self.sessionInteractor.loadSession { _ in
                self.loadMenus(completion: completion)
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
				logInfo("ERROR: \(message)")
				completion(false, [], NSError.OCMError(message: nil, debugMessage: kLocaleOcmErrorContent, baseError: nil))
			}
		}
	}
	
}
