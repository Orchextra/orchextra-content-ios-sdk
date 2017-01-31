//
//  OrchextraWrapper.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//
import Foundation
import GIGLibrary
import Orchextra

class OrchextraWrapper: NSObject, OrchextraLoginDelegate {
	
	let orchextra: Orchextra = Orchextra.sharedInstance()
	let config = ORCSettingsDataManager()
    
    public static let shared: OrchextraWrapper = OrchextraWrapper()
    
    override init() {
        super.init()
        self.orchextra.loginDelegate = self
    }
    
    func loadAccessToken() -> String? {
        return self.config.accessToken()
    }
    
    func loadClientToken() -> String? {
        return self.config.clientToken()
    }
	
	func loadApiKey() -> String? {
		self.checkOrchextra()
		return self.config.apiKey()
	}
	
	func loadApiSecret() -> String? {
		self.checkOrchextra()
		return self.config.apiSecret()
	}
	
	func setCountry(code: String) {
		guard let bussinesUnit = ORCBusinessUnit(name: code) else {
			return LogWarn("Invalid country code \(code)")
		}
		
		self.orchextra.setDeviceBussinessUnits([bussinesUnit])
        self.orchextra.commitConfiguration()
	}
	
	func setUser(id: String?) {
		self.orchextra.unbindUser()

		guard let id = id else { return }
		let user = self.orchextra.currentUser()
		user.crmID = id
        
		self.orchextra.bindUser(user)
	}
    
    func unbindUser() {
        self.orchextra.unbindUser()
    }
	
	func startWith(apikey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
		self.orchextra.setApiKey(apikey, apiSecret: apiSecret) { success, _ in
            if success {
				completion(.success(success))
			} else {
				//				completion(.error(error as? NSError))
			}
		}
	}
    
    func startScanner() {
        self.orchextra.startScanner()
    }
    
    func startVuforia() {

        if  VuforiaOrchextra.sharedInstance().isVuforiaEnable() {
            VuforiaOrchextra.sharedInstance().startImageRecognition()
        }
    }
	
	
	// MARK: - Private Helpers
	
	private func checkOrchextra() {
		if !self.config.isOrchextraRunning() {
			LogInfo("Orchextra is not running! You must set the api key and api secret first.")
		}
	}
    
    // MARK: OrchextraLoginDelegate
    func didUpdateAccessToken(_ accessToken: String?) {
        OCM.shared.didUpdate(accessToken: accessToken)
    }
    
}
