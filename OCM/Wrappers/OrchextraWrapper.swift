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
    var completionBussinesUnit: (() -> Void)?
    
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
    
    func loadAccessToken() -> String? {
        return self.orchextra.accesstoken()
    }
    
    func setEnvironment(host: Environment) {
        self.orchextra.environment = host
        
    }
    
    func set(businessUnit: String, completion: @escaping () -> Void) {
        self.completionBussinesUnit = completion
        let bussinesUnit: BusinessUnit = BusinessUnit(name: businessUnit)
        self.orchextra.setDeviceBusinessUnits([bussinesUnit])
        self.orchextra.bindDevice()
    }
	
	func bindUser(with identifier: String?, completion: @escaping () -> Void) {
        self.orchextra.unbindUser()
        guard let identifier = identifier,
            let user = self.orchextra.currentUser()
            else { logWarn("When bindUser, the Identifier is missing"); return }
        user.crmId = identifier
        self.completionBussinesUnit = completion
        self.orchextra.bindUser(user)
	}
    
    func unbindUser() {
        self.orchextra.unbindUser()
    }
	
    func currentUser() -> String? {
        return self.orchextra.currentUser()?.crmId
    }
    
    func startWith(apikey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.orchextra.start(with: apikey, apiSecret: apiSecret, completion: completion)
        self.orchextra.delegate = self
	}
    
//    func startScanner() {
//        self.orchextra.openScanner()
//    }
    
    func openScanner(completion: ((String) -> Void)?) {
        self.orchextra.openScanner(completion: completion)
    }
}

// MARK: - ORXDelegate

extension OrchextraWrapper: ORXDelegate {
    func bindDidCompleted(result: Result<[AnyHashable: Any], Error>) {
        switch result {
        case .success(let bindValues):
            LogInfo("Values of bingind: \(bindValues)")
        case .error(let error):
            LogWarn("Error binding: \(error.localizedDescription)")
        }
        
        self.completionBussinesUnit?()
    }
    
    public func customScheme(_ scheme: String) {
        guard let url = URLComponents(string: scheme) else { logWarn("URLComponents is nil"); return }
        OCM.shared.delegate?.customScheme(url)
    }
    
    public func triggerFired(_ trigger: Trigger) {
        
    }
}

//// MARK: - OrchextraLoginDelegate
//extension OrchextraWrapper: OrchextraLoginDelegate {
//
//    func didUpdateAccessToken(_ accessToken: String?) {
//        // Logic to check if the user did login or logout
//        let didLogin = (self.accessToken != accessToken && Config.isLogged == true)
//        let didLogout = (self.accessToken != accessToken && self.accessToken != nil && Config.isLogged == false)
//        if didLogin {
//            ActionScheduleManager.shared.performActions(for: .login)
//        } else if didLogout {
//            ActionScheduleManager.shared.performActions(for: .logout)
//        }
//        OCM.shared.delegate?.didUpdate(accessToken: accessToken)
//        self.accessToken = accessToken
//    }
//}
