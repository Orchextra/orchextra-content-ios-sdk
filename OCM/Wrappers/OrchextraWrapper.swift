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

class OrchextraWrapper: NSObject {
	
	let orchextra: Orchextra = Orchextra.sharedInstance()
	let config = ORCSettingsDataManager()
    public static let shared: OrchextraWrapper = OrchextraWrapper()
    
    override init() {
        super.init()
        self.orchextra.loginDelegate = self
        switch OCM.shared.logLevel {
        case .debug:
            Orchextra.logLevel(.all)
        case .error:
            Orchextra.logLevel(.error)
        case .info:
            Orchextra.logLevel(.debug)
        case .none:
            Orchextra.logLevel(.off)
        }
    }
    
    func loadAccessToken() -> String? {
        return self.config.accessToken()
    }
    
    func loadClientToken() -> String? {
        return self.config.clientToken()
    }
	
	func loadApiKey() -> String? {
		return self.config.apiKey()
	}
	
	func loadApiSecret() -> String? {
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
        
        guard let identifier = identifier else { logWarn("When setUser, the Identifier is missing"); return }
        let user = self.orchextra.currentUser()
        user.crmID = identifier
        
        self.orchextra.bindUser(user)
    }
	
	func bindUser(with identifier: String?) {
		self.orchextra.unbindUser()

        guard let identifier = identifier else { logWarn("When bindUser, the Identifier is missing"); return }
		let user = self.orchextra.currentUser()
		user.crmID = identifier
        
		self.orchextra.bindUser(user)
	}
    
    func unbindUser() {
        self.orchextra.unbindUser()
    }
	
    func startWith(apikey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.orchextra.setApiKey(apikey, apiSecret: apiSecret) { success, error in
            if success {
                completion(.success(success))
            } else {
                completion(.error(error))
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
}

// MARK: - OrchextraLoginDelegate

extension OrchextraWrapper: OrchextraLoginDelegate {
    
    func didUpdateAccessToken(_ accessToken: String?) {

        OCM.shared.delegate?.didUpdate(accessToken: accessToken)
    }
}

// MARK: - OrchextraCustomActionDelegate

extension OrchextraWrapper: OrchextraCustomActionDelegate {

    func executeCustomScheme(_ scheme: String) {
        
        guard let url = URLComponents(string: scheme) else { return }
        OCM.shared.delegate?.customScheme(url)
    }
}
