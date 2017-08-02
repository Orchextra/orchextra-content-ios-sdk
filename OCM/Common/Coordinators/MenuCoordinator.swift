//
//  MenuCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

typealias MenusResult = (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void

class MenuCoordinator: ReachabilityWrapperDelegate {
    
    // MARK: - Static public attributes
    
    static let shared = MenuCoordinator(
        sessionInteractor: SessionInteractor(
            session: Session.shared,
            orchextra: OrchextraWrapper.shared
        ),
        menuInteractor: MenuInteractor(
            sessionInteractor: SessionInteractor(
                session: Session.shared,
                orchextra: OrchextraWrapper.shared
            ),
            contentDataManager: .sharedDataManager
        )
    )
    
    // MARK: - Private attributes
    
    private var menus: [Menu] = []
    private let sessionInteractor: SessionInteractorProtocol
    private let menuInteractor: MenuInteractor
    
    init(sessionInteractor: SessionInteractorProtocol, menuInteractor: MenuInteractor) {
        self.sessionInteractor = sessionInteractor
        self.menuInteractor = menuInteractor
    }
    
    deinit {
    }
    
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
                self.menus = menus
                completion(true, menus, nil)
			
            case .empty:
                self.menus = []
				completion(true, [], nil)
				
			case .error(let message):
				logInfo("ERROR: \(message)")
				completion(false, [], NSError.OCMError(message: nil, debugMessage: kLocaleOcmErrorContent, baseError: nil))
			}
		}
	}
    
    // MARK: - ReachabilityWrapperDelegate
    
    func reachabilityChanged(with status: NetworkStatus) {
        switch status {
        case .reachableViaMobileData, .reachableViaWiFi:
            self.menuInteractor.loadMenus(forcingDownload: true) { result in
                switch result {
                case .success(let menus):
                    if self.menus != menus {
                        self.menus = menus
                        OCM.shared.delegate?.menusDidRefresh(menus)
                    }
                case .empty:
                    if self.menus != [] {
                        self.menus = []
                        OCM.shared.delegate?.menusDidRefresh([])
                    }
                case .error: break
                }
            }
        default: break
        }
    }
}
