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
    
    private var accessToken: String?
    
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
	
	func set(businessUnit: String) {
		guard let bussinesUnit = ORCBusinessUnit(name: businessUnit) else {
			return logWarn("Invalid business unit \(businessUnit)")
		}
        if OCM.shared.offlineSupportConfig !=  nil {
            OCM.shared.resetCache() // To delete all stored data
        }
		self.orchextra.setDeviceBussinessUnits([bussinesUnit])
        self.orchextra.commitConfiguration()
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
	
    func currentUser() -> String? {
        return self.orchextra.currentUser().crmID
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
        // Logic to check if the user did login or logout
        let didLogin = (self.accessToken != accessToken && Config.isLogged == true)
        let didLogout = (self.accessToken != accessToken && self.accessToken != nil && Config.isLogged == false)
        if didLogin {
            ActionScheduleManager.shared.performActions(for: .login)
        } else if didLogout {
            ActionScheduleManager.shared.performActions(for: .logout)
        }
        OCM.shared.delegate?.didUpdate(accessToken: accessToken)
        self.accessToken = accessToken
    }
}

// MARK: - OrchextraCustomActionDelegate

extension OrchextraWrapper: OrchextraCustomActionDelegate {

    func executeCustomScheme(_ scheme: String) {
        
        guard let url = URLComponents(string: scheme) else { logWarn("URLComponents is nil"); return }
        OCM.shared.delegate?.customScheme(url)
    }
}
