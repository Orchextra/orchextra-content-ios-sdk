//
//  ContentVersionInteractor.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 13/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ContentVersionInteractorProtocol {
    func loadContentVersion(completionHandler: @escaping (Result<Bool, NSError>) -> Void)
}

class ContentVersionInteractor: ContentVersionInteractorProtocol {

    // MARK: Private properties
    
    private let contentDataManager: ContentDataManager
    
    // MARK: Initializer
    
    init(contentDataManager: ContentDataManager) {
        self.contentDataManager = contentDataManager
    }
    
    // MARK: Public methods
    
    func loadContentVersion(completionHandler: @escaping (Result<Bool, NSError>) -> Void) {
        self.contentDataManager.loadContentVersion { result in
            switch result {
            case .success(let version):
                if let currentContentVersion = UserDefaultsManager.currentContentVersion() {
                    // Version locally stored, compare against server version
                    if version != currentContentVersion {
                        logInfo("!!! Different version, should update all data")
                        // Different version, should update all data
                        UserDefaultsManager.setContentVersion(version)
                        completionHandler(.success(true))
                    } else {
                        logInfo("!!! Same version, no need for update")
                        // Same version, no need for update
                       completionHandler(.success(false))
                    }
                } else {
                    logInfo("!!! No version locally stored, should update all data")
                    // No version locally stored, should update all data
                    UserDefaultsManager.setContentVersion(version)
                    completionHandler(.success(true))
                }
            case .error(let error):
                completionHandler(.error(error.error))
            }
        }
    }
}
