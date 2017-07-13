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

class OrchextraWrapper: NSObject, OrchextraLoginDelegate, OrchextraCustomActionDelegate {
	
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
    
    func setEnvironment(host: String) {
        self.config.setEnvironment(host)
    }
    
    @available(*, deprecated: 2.0, message: "use set: instead", renamed: "set")
    func setCountry(code: String) {
        guard let bussinesUnit = ORCBusinessUnit(name: code) else {
            return logWarn("Invalid country code \(code)")
        }
        
        self.orchextra.setDeviceBussinessUnits([bussinesUnit])
        self.orchextra.commitConfiguration()
    }
	
	func set(businessUnit: String) {
		guard let bussinesUnit = ORCBusinessUnit(name: businessUnit) else {
			return logWarn("Invalid business unit \(businessUnit)")
		}
		
		self.orchextra.setDeviceBussinessUnits([bussinesUnit])
        self.orchextra.commitConfiguration()
	}
    
     @available(*, deprecated: 2.0, message: "use bindUser: instead", renamed: "bindUser")
    func setUser(identifier: String?) {
        self.orchextra.unbindUser()
        
        guard let identifier = identifier else { return }
        let user = self.orchextra.currentUser()
        user.crmID = identifier
        
        self.orchextra.bindUser(user)
    }
	
	func bindUser(with identifier: String?) {
		self.orchextra.unbindUser()

		guard let identifier = identifier else { return }
		let user = self.orchextra.currentUser()
		user.crmID = identifier
        
		self.orchextra.bindUser(user)
	}
    
    func unbindUser() {
        self.orchextra.unbindUser()
    }
	
	func startWith(apikey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        Orchextra.logLevel(.error)
		self.orchextra.setApiKey(apikey, apiSecret: apiSecret) { success, _ in
            if success {
				completion(.success(success))
			} else {
				//completion(.error(error as? NSError))
			}
		}
        self.orchextra.delegate = self
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
			logInfo("Orchextra is not running! You must set the api key and api secret first.")
		}
	}
    
    // MARK: - OrchextraLoginDelegate
    
    func didUpdateAccessToken(_ accessToken: String?) {
        
        OCM.shared.delegate?.didUpdate(accessToken: accessToken)
    }
    
    // MARK: - OrchextraCustomActionDelegate
    
    func executeCustomScheme(_ scheme: String) {
        
        guard let url = URLComponents(string: scheme) else { return }
        OCM.shared.delegate?.customScheme(url)
    }

}
