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

typealias Credentials = (clientToken: String, accessToken: String)


struct OrchextraWrapper {
	
	let orchextra: Orchextra = Orchextra.sharedInstance()
	let config = ORCSettingsDataManager()
	
	func loadApiKey() -> String? {
		self.checkOrchextra()
		return self.config.apiKey()
	}
	
	func loadApiSecret() -> String? {
		self.checkOrchextra()
		return self.config.apiSecret()
	}
	
	func setCountry(code: String) {
		guard let bussinesUnit = ORCBusinessUnit(prefix: "", name: code) else {
			return LogWarn("Invalid country code \(code)")
		}
		
		self.orchextra.setUserBusinessUnits([bussinesUnit])
	}
	
	func setUser(id: String?) {
		self.orchextra.unbindUser()

		guard let id = id else { return }
		let user = self.orchextra.currentUser()
		user?.crmID = id
		self.orchextra.bindUser(user)
	}
	
	func startWith(apikey: String, apiSecret: String, completion: @escaping (Result<(clientToken: String, accessToken: String), Error>) -> Void) {
		self.orchextra.setApiKey(apikey, apiSecret: apiSecret) { success, error in
			if success {
				let credentials: Credentials = (
					clientToken: self.config.clientToken(),
					accessToken: self.config.accessToken()
				)
				
				completion(.success(credentials))
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
}
