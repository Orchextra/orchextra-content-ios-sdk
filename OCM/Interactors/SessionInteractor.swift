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
  //  func hasSession() -> Bool
    func renewSession(completion: @escaping (Result<Bool, String>) -> Void)
    func loadSession(completion: @escaping (Result<Bool, String>) -> Void)
}

class SessionInteractor: SessionInteractorProtocol {
	
	var session: Session
    let orchextra: OrchextraWrapper
    private var startOrxTimers: [Timer] = []
    static let shared: SessionInteractor = SessionInteractor(
        session: .shared,
        orchextra: .shared
    )
    
	init(session: Session, orchextra: OrchextraWrapper) {
		self.session = session
		self.orchextra = orchextra
	}
	
    /*  // TODO EDU
	func hasSession() -> Bool {
		guard self.orchextra.loadClientToken() != nil && self.orchextra.loadAccessToken() != nil else { return false }
		
		return true
	} */
	
	func loadSession(completion: @escaping (Result<Bool, String>) -> Void) {
	//	self.loadKeyAndSecret()  // TODO EDU
		
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
    
    func renewSession(completion: @escaping (Result<Bool, String>) -> Void) {
        // We add this timer in order to fix a bug of Orx loading the second start request
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(finishTimer(_:)), userInfo: completion, repeats: false)
        self.startOrxTimers.append(timer)
        logInfo("Renewing session")
        self.loadSession { result in
            completion(result)
            guard let index = self.startOrxTimers.index(of: timer) else { logWarn("startOrxTimers is nil"); return }
            timer.invalidate()
            self.startOrxTimers.remove(at: index)
        }
    }
    
    // MARK: - Private methods
    
    @objc private func finishTimer(_ timer: Timer) {
        logInfo("The request of start failed, return a success in order to can continue with process")
        guard let index = self.startOrxTimers.index(of: timer) else { logWarn("startOrxTimers is nil"); return }
        if let completion = timer.userInfo as? (Result<Bool, Error>) -> Void {
            completion(.success(true))
        }
        timer.invalidate()
        self.startOrxTimers.remove(at: index)
    }
	  // TODO EDU
    /*
	private func loadKeyAndSecret() {
		self.session.apiSecret = self.orchextra.loadApiSecret()
		self.session.apiKey = self.orchextra.loadApiKey()
	}*/
}
