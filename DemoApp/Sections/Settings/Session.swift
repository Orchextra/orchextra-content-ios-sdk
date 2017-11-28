//
//  Session.swift
//  Orchextra
//
//  Created by Judith Medina on 14/08/2017.
//  Copyright © 2017 Gigigo Mobile Services S.L. All rights reserved.
//

import Foundation
import GIGLibrary

class Session {
    
    static let shared = Session()
    let userDefault: UserDefaults
    
    private let keyApiKey = "keyApiKey"
    private let keyApiSecret = "keyApiSecret"

    var apiKey: String?
    var apiSecret: String?
    
    init(userDefault: UserDefaults = UserDefaults()) {
        self.userDefault = userDefault
    }

    // MARK: - Public

    func saveORX(apikey: String, apisecret: String) {
        self.userDefault.set(apikey, forKey: keyApiKey)
        self.userDefault.set(apisecret, forKey: keyApiSecret)
        self.userDefault.synchronize()
    }
    
    func loadORXCredentials() -> (apikey: String, apisecret: String)? {
        guard let apikey = self.userDefault.value(forKey: keyApiKey) as? String,
            let apisecret = self.userDefault.value(forKey: keyApiSecret) as? String else {
                return nil
        }
        return (apikey, apisecret)
    }
}
