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
    var completionBindUser: (() -> Void)?
    
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
        guard let identifier = identifier,
            let user = self.orchextra.currentUser()
            else { logWarn("When bindUser, the Identifier is missing"); return }
        user.crmId = identifier
        self.completionBindUser = completion
        self.orchextra.bindUser(user)
	}
    
    func unbindUser(completion: @escaping () -> Void) {
        self.completionBindUser = completion
        self.orchextra.unbindUser()
    }
	
    func currentUser() -> String? {
        return self.orchextra.currentUser()?.crmId
    }
    
    func startWith(apikey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.orchextra.start(with: apikey, apiSecret: apiSecret, completion: completion)
        self.orchextra.enableProximity(enable: true)
        self.orchextra.enableEddystones(enable: true)
        self.orchextra.delegate = self
	}
    
    func startScanner() {
        self.orchextra.openScanner()
    }
    
    func scan(completion: @escaping(ScannerResult?) -> Void) {
        self.orchextra.scan { (result) in
            switch result {
            case .success(let scanResult):
                completion(scanResult)
            case .error(let error):
                LogWarn("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

// MARK: - ORXDelegate

extension OrchextraWrapper: ORXDelegate {
    
    func deviceBindDidComplete(result: Result<[AnyHashable: Any], Error>) {
        switch result {
        case .success(let bindValues):
            LogInfo("Values of bingind: \(bindValues)")
        case .error(let error):
            LogWarn("Error binding: \(error.localizedDescription)")
        }
        self.completionBussinesUnit?()
        self.completionBussinesUnit = nil
    }
    
    func userBindDidComplete(result: Result<[AnyHashable: Any], Error>) {
        switch result {
        case .success(let bindValues):
            LogInfo("Values of User of bingind: \(bindValues)")
        case .error(let error):
            LogWarn("Error User binding: \(error.localizedDescription)")
        }
        self.completionBindUser?()
        self.completionBindUser = nil
    }
    
    public func customScheme(_ scheme: String) {
        guard let url = URLComponents(string: scheme) else { logWarn("URLComponents is nil"); return }
        OCM.shared.schemeDelegate?.openURLScheme(url)
    }
    
    public func triggerFired(_ trigger: Trigger) {
        
    }
}
