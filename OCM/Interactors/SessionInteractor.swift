//
//  SessionInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol SessionInteractorProtocol {
    func hasSession() -> Bool
    func sessionExpired()
    func loadSession(completion: @escaping (Result<Bool, String>) -> Void)
}

class SessionInteractor: SessionInteractorProtocol {
	
	var session: Session
	let orchextra: OrchextraWrapper
	
	init(session: Session, orchextra: OrchextraWrapper) {
		self.session = session
		self.orchextra = orchextra
	}
	
	func hasSession() -> Bool {
		guard self.orchextra.loadClientToken() != nil && self.orchextra.loadAccessToken() != nil else { return false }
		
		return true
	}
	
	func sessionExpired() {
        orchextra.unbindUser()
	}
	
	func loadSession(completion: @escaping (Result<Bool, String>) -> Void) {
		self.loadKeyAndSecret()
		
		guard let apiKey = self.session.apiKey else {
			return completion(.error("No API key set. First start Orchextra"))
		}
		
		guard let apiSecret = self.session.apiSecret else {
			return completion(.error("No API Secret set. First start Orchextra"))
		}
		
		self.orchextra.startWith(apikey: apiKey, apiSecret: apiSecret) { result in
			switch result {
			
			case .success:
				completion(.success(true))
				
			case .error:
				completion(.error("Could not load credentials..."))
			}
		}
	}
	
	
	// MARK: - Private Helpers
	
	private func loadKeyAndSecret() {
		self.session.apiSecret = self.orchextra.loadApiSecret()
		self.session.apiKey = self.orchextra.loadApiKey()
	}
}
