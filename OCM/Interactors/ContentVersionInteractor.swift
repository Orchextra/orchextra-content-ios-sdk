//
//  ContentVersionInteractor.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 13/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol ContentVersionInteractorProtocol {
    func loadContentVersion(completionHandler: @escaping (Bool) -> Void)
}

class ContentVersionInteractor: ContentVersionInteractorProtocol {

    // MARK: Private properties
    
    private let contentDataManager: ContentDataManager
    
    // MARK: Initializer
    
    init(contentDataManager: ContentDataManager) {
        self.contentDataManager = contentDataManager
    }
    
    // MARK: Public methods
    
    func loadContentVersion(completionHandler: @escaping (Bool) -> Void) {
        self.contentDataManager.loadContentVersion { result in
            switch result {
            case .success(let version):
                // TODO: Should store latest version on User Defaults and also read the expiration date, WS does not include it yet !!!
                if version != "storedVersionToDo!!!" {
                    // Different version, should update all data
                    completionHandler(true)
                } else {
                    // Same version, no need for update
                    completionHandler(false)
                }
            case .error:
                // TODO: Should return an error.
                completionHandler(false)
            }
        }
    }
}
