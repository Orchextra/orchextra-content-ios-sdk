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
    
    // TODO EDU documentar esto
    func run(action: Action, viewController: UIViewController?)
    func executable(action: Action)
}

class ActionInteractor: ActionInteractorProtocol {
	
    let contentDataManager: ContentDataManager
    let ocm: OCM
    let actionScheduleManager: ActionScheduleManager
    
    init() {
        self.contentDataManager = .sharedDataManager
        self.ocm = OCM.shared
        self.actionScheduleManager = ActionScheduleManager.shared
    }
    
    init(contentDataManager: ContentDataManager, ocm: OCM, actionScheduleManager: ActionScheduleManager) {
        self.contentDataManager = contentDataManager
        self.ocm = ocm
        self.actionScheduleManager = actionScheduleManager
    }
    
    // MARK: Public method
	
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
    
    func run(action: Action, viewController: UIViewController?) {
        
        switch action.typeAction {
        case .actionArticle, .actionWebview, .actionCard:
            guard let fromVC = viewController else { logWarn("viewController is nil"); return }
            self.ocm.wireframe.showMainComponent(with: action, viewController: fromVC)
            
        case .actionExternalBrowser, .actionBrowser:
            self.launchOpenUrl(action, viewController: viewController)
        
        case .actionScan, .actionVuforia:
            if action.preview != nil, let fromVC = viewController {
                OCM.shared.wireframe.showMainComponent(with: action, viewController: fromVC)
            } else {
                self.executable(action: action)
            }
        
        case .actionContent:
            // Do Nothing
            break
            
        case .actionVideo:
            if action.preview != nil {
                guard let viewController = viewController else { logWarn("viewController is nil"); return }
                self.ocm.wireframe.showMainComponent(with: action, viewController: viewController)
            } else {
                let actionViewer = ActionViewer(action: action, ocm: self.ocm)
                guard let viewController = actionViewer.view() else { logWarn("view is nil"); return }
                self.ocm.wireframe.show(viewController: viewController)
            }
            
        case .actionDeepLink:
            if action.preview != nil {
                guard let fromVC = viewController else { logWarn("viewController is nil"); return }
                self.ocm.wireframe.showMainComponent(with: action, viewController: fromVC)
            } else {
                self.executable(action: action)
            }
            
        case .actionBanner:
            if action.preview != nil {
                guard let fromVC = viewController else { logWarn("viewController is nil"); return }
                self.ocm.wireframe.showMainComponent(with: action, viewController: fromVC)
            }
        }
    }
    
    func executable(action: Action) {
        
        switch action.typeAction {
        case .actionArticle, .actionCard, .actionContent, .actionBanner:
            // Do Nothing
            break
            
        case .actionScan, .actionVuforia:
            OrchextraWrapper.shared.startScanner()
            
        case .actionExternalBrowser, .actionBrowser:
            self.launchOpenUrl(action, viewController: nil)
            
        case .actionWebview:
            let actionViewer = ActionViewer(action: action, ocm: self.ocm)
            guard let viewController = actionViewer.view() else { logWarn("view is nil"); return }
            self.ocm.wireframe.show(viewController: viewController)
            
        case .actionVideo:
            let actionViewer = ActionViewer(action: action, ocm: self.ocm)
            guard let viewController = actionViewer.view() else { logWarn("view is nil"); return }
            self.ocm.wireframe.show(viewController: viewController)
            
        case .actionDeepLink:
            guard let actionCustomScheme = action as? ActionCustomScheme else { logWarn("action doesn't is a ActionCustomScheme"); return }
            self.ocm.delegate?.customScheme(actionCustomScheme.url)
        }
    }
    
    // MARK: Private Method
    
    private func launchOpenUrl(_ action: Action, viewController: UIViewController?) {
        var output: ActionOut?
        var url: URL
        var federated: [String: Any]?
        var preview: Preview?
        
        if let actionParse = action as? ActionExternalBrowser {
            output = actionParse.output
            url = actionParse.url
            federated = actionParse.federated
            preview = actionParse.preview
        } else if let actionParse = action as? ActionBrowser {
            output = actionParse.output
            url = actionParse.url
            federated = actionParse.federated
            preview = actionParse.preview
        } else {
            logWarn("Miss necesary action for open url")
            return
        }
        
        if self.ocm.isLogged {
            if let federatedData = federated, federatedData["active"] as? Bool == true {
                output?.blockView()
                self.ocm.delegate?.federatedAuthentication(federatedData, completion: { params in
                    
                    output?.unblockView()
                    var urlFederated = url.absoluteString
                    
                    guard let params = params else {
                        logWarn("urlFederatedAuth params is null")
                        self.executeLaunch(action, viewController: viewController, url: url, preview: preview)
                        return
                    }
                    
                    for (key, value) in params {
                        urlFederated = self.concatURL(url: urlFederated, key: key, value: value)
                    }
                    
                    guard let urlFederatedAuth = URL(string: urlFederated) else {
                        logWarn("urlFederatedAuth is not a valid URL")
                        self.executeLaunch(action, viewController: viewController, url: url, preview: preview)
                        return
                        
                    }
                    url = urlFederatedAuth
                    self.executeLaunch(action, viewController: viewController, url: url, preview: preview)
                })
            } else {
                logInfo("open: \(String(describing: url))")
                self.executeLaunch(action, viewController: viewController, url: url, preview: preview)
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func executeLaunch(_ action: Action, viewController: UIViewController?, url: URL, preview: Preview?) {
        switch action.typeAction {
        case .actionBrowser:
            self.launchAction(action, viewController: viewController, url: url, preview: preview)
        case .actionExternalBrowser:
            UIApplication.shared.openURL(url)
        default:
            break
        }
    }
    
    
    private func launchAction(_ action: Action, viewController: UIViewController?, url: URL, preview: Preview?) {
        if preview != nil {
            guard let fromVC = viewController else {
                self.ocm.wireframe.showBrowser(url: url)
                return
            }
            self.ocm.wireframe.showMainComponent(with: action, viewController: fromVC)
        } else {
            self.ocm.wireframe.showBrowser(url: url)
        }
    }
    
    private func concatURL(url: String, key: String, value: Any) -> String {
        guard let valueURL = value as? String else {
            LogWarn("Value URL is not a String")
            return url
        }
        
        var urlResult = url
        if url.contains("?") {
            urlResult = "\(url)&\(key)=\(valueURL)"
        } else {
            urlResult = "\(url)?\(key)=\(valueURL)"
        }
        return urlResult
    }
    
}
