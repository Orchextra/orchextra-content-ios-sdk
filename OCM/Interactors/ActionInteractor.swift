//
//  ActionInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

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
                completion(action, nil)
            case .error(let error):
                // Check if error is because of the action is login-restricted
                if error._userInfo?["OCM_ERROR_MESSAGE"] as? String == "requiredAuth" {
                    self.ocm.delegate?.contentRequiresUserAuthentication {
                        if Config.isLogged {
                            // Maybe the Orchextra login doesn't finish yet, so
                            // We save the pending action to perform when the login did finish
                            // If the user is already logged in, the action will be performed automatically
                            self.actionScheduleManager.registerAction(for: .login) {
                                self.action(forcingDownload: force, with: identifier, completion: completion)
                            }
                        } else {
                            completion(nil, error)
                        }
                    }
                } else {
                    completion(nil, error)
                }
            }
        }
    }
    
    
    // MARK: - Actions
    
    func run(viewController: UIViewController? = nil) {
        
    }
    
    func executable(action: Action) {
        
        switch action.typeAction {
        case .actionArticle:
            break
            
        case .actionWebview:
            guard let viewController = self.view() else { logWarn("view is nil"); return }
            self.ocm.wireframe.show(viewController: viewController)
            break
            
        case .actionCard:
            break
            
        case .actionContent:
            break
            
        case .actionVideo:
            break
            
        case .actionExternalBrowser:
            break
            
        case .actionBrowser:
            break
            
        case .actionDeepLink:
            break
            
        case .actionScan:
            break
            
        case .actionVuforia:
            break
        }
    }
    
}
