//
//  ActionInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

protocol ActionInteractorProtocol {
    
    /// Method to get an action asynchronously
    ///
    /// - Parameters:
    ///   - forcindDownload: Set to true if you want to force the download
    ///   - url: The url of the action
    ///   - completion: Block to return the action
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void)
}

struct ActionInteractor: ActionInteractorProtocol {
	
    let contentDataManager: ContentDataManager
    let ocm: OCM
    let actionScheduleManager: ActionScheduleManager
	
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        self.contentDataManager.loadElement(forcingDownload: force, with: identifier) { result in
            switch result {
            case .success(let action):
                if action.requiredAuth == "logged" && !Config.isLogged {
                    self.requireLoginOfAction(action, error: nil, forcingDownload: force, with: identifier, completion: completion)
                } else {
                    completion(action, nil)
                }
            case .error(let error):
                // Check if error is because of the action is login-restricted
                if error._userInfo?["OCM_ERROR_MESSAGE"] as? String == "requiredAuth" {
                    self.requireLoginOfAction(nil, error: error, forcingDownload: force, with: identifier, completion: completion)
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    private func requireLoginOfAction(_ action: Action?, error: Error?, forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        self.ocm.delegate?.contentRequiresUserAuthentication {
            if Config.isLogged {
                // Maybe the Orchextra login doesn't finish yet, so
                // We save the pending action to perform when the login did finish
                // If the user is already logged in, the action will be performed automatically
                self.actionScheduleManager.registerAction(for: .login) {
                    self.action(forcingDownload: force, with: identifier, completion: completion)
                }
            } else {
                completion(action, error)
            }
        }
    }
}
