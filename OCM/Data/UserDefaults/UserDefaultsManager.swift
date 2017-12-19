//
//  UserDefaultsManager.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 18/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    static let contentVersion = "OCMContentVersion"
}

class UserDefaultsManager {
    
    /// Updates the content version on `UserDefaults`.
    ///
    /// - Parameters:
    ///     - version: `String` value for the content version retrieved from server.
    static func setContentVersion(_ version: String) {
        guard !version.isEmpty else { return }
        UserDefaults.standard.set(version, forKey: UserDefaultsKeys.contentVersion)
        UserDefaults.standard.synchronize()

    }
    
    /// Retrieves the content version from `UserDefaults`.
    ///
    /// - Returns: `String` value with the stored content version, `nil` if not set yet.
    static func currentContentVersion() -> String? {
        let version = UserDefaults.standard.string(forKey: UserDefaultsKeys.contentVersion)
        return version
    }
    
    /// Resets the value for the content version on `UserDefaults`.
    static func resetContentVersion() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.contentVersion)
    }
    
}
