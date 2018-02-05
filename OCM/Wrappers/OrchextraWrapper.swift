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
	
    let orchextra: Orchextra = Orchextra.shared
    public static let shared: OrchextraWrapper = OrchextraWrapper()
    
    private var accessToken: String?
    
    override init() {
        super.init()
 //       self.orchextra.loginDelegate = self
        switch OCM.shared.logLevel {
        case .debug:
            self.orchextra.logLevel = .debug
        case .error:
            self.orchextra.logLevel = .error
        case .info:
            self.orchextra.logLevel = .info
        case .none:
           self.orchextra.logLevel = .none
        }
    }
    
    func setEnvironment(host: Environment) {
        self.orchextra.environment = host
        
    }
	
    func set(businessUnit: String) {
        let bussinesUnit = BusinessUnit(name: businessUnit)
        self.orchextra.setDeviceBusinessUnits([bussinesUnit])
        self.orchextra.commitConfiguration()
    }

    
    /*
    func set(businessUnit: String, completion: @escaping () -> Void) {
		guard let bussinesUnit = ORCBusinessUnit(name: businessUnit) else {
			return logWarn("Invalid business unit \(businessUnit)")
		}
		
		self.orchextra.setDeviceBussinessUnits([bussinesUnit])
        
        self.orchextra.commitConfiguration({ success, error in
            if !success {
                logWarn(error.localizedDescription)
            }
            completion()
        })
	}*/
	
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
        if didLogin {
            ActionScheduleManager.shared.performActions(for: "requiredAuth")
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
