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
    
    /// Runs an action, if associated with a view the result is shown on a
    /// provided View Controller
    ///
    /// - Parameters:
    ///   - action: Action to be runned
    ///   - viewController: View Controller that will contain the action's associated section
    func run(action: Action, viewController: UIViewController?)
    
    /// Method to execute action
    ///
    /// - Parameters:
    ///   - action: Model action with which the action type was segmented and the data to be loaded.
    func execute(action: Action)
}

//swiftlint:disable cyclomatic_complexity

class ActionInteractor: ActionInteractorProtocol {
	
    let contentDataManager: ContentDataManager
    let ocmController: OCMController
    let actionScheduleManager: ActionScheduleManager
    
    init() {
        self.contentDataManager = .sharedDataManager
        self.ocmController = OCMController.shared
        self.actionScheduleManager = ActionScheduleManager.shared
    }
    
    init(contentDataManager: ContentDataManager, ocmController: OCMController, actionScheduleManager: ActionScheduleManager) {
        self.contentDataManager = contentDataManager
        self.ocmController = ocmController
        self.actionScheduleManager = actionScheduleManager
    }
    
    // MARK: Public method
	
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        self.contentDataManager.loadElement(forcingDownload: force, with: identifier) { result in
            switch result {
            case .success(let action):
                if let customProperties = action.customProperties {
                    self.requireValidationOfAction(action, customProperties: customProperties, forcingDownload: force, with: identifier, completion: completion)
                } else {
                    self.validateAction(action, completion: completion)
                }
            case .error(let error):
                completion(nil, error)
            }
        }
    }
    
    private func requireValidationOfAction(_ action: Action?, customProperties: [String: Any], forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        
        self.ocmController.customBehaviourDelegate?.contentNeedsValidation(
            for: customProperties,
            completion: { (succeed) in
                if succeed {
                    // If the action does not require user authentication is immediately triggered.
                    // Otherwise, it will be triggered if the user is logged in, if not the action will be
                    // scheduled to be triggered as soon as login process is finished (including Orchextra's login).
                    self.actionScheduleManager.registerAction(for: customProperties) {
                        self.contentDataManager.loadElement(forcingDownload: force, with: identifier) { result in
                            switch result {
                            case .success(let action):
                                self.validateAction(action, completion: completion)
                            case .error(let error):
                                completion(nil, error)
                            }
                        }
                    }
                } else {
                    completion(nil, nil)
                }
            })
    }
    
    private func canPerformAction(_ action: Action) -> (can: Bool, error: Error?) {
        switch action {
        case is ActionExternalBrowser:
            guard let external = action as? ActionExternalBrowser else { return (true, nil) }
            if UIApplication.shared.canOpenURL(external.url) {
                return (true, nil)
            } else {
                return (false, NSError(message: localize("error_unexpected")))
            }
        default:
            return (true, nil)
        }
    }
    
    private func validateAction(_ action: Action, completion: @escaping (Action?, Error?) -> Void) {
        if let error = self.canPerformAction(action).error {
            completion(nil, error)
        } else {
            completion(action, nil)
        }
    }
    
    // MARK: - Actions
    
    func run(action: Action, viewController: UIViewController?) {
        
        switch action.actionType {
        case .article, .card, .webview:
            guard let fromVC = viewController else { logWarn("viewController is nil"); return }
            self.ocmController.wireframe?.showMainComponent(with: action, viewController: fromVC)
            
        case .externalBrowser, .browser:
            self.launchOpenUrl(action, viewController: viewController)
        
        case .scan:
            if action.preview != nil, let fromVC = viewController {
                self.ocmController.wireframe?.showMainComponent(with: action, viewController: fromVC)
            } else {
                self.execute(action: action)
            }
        
        case .content:
            // Do Nothing
            break
            
        case .video:
            if action.preview != nil {
                guard let viewController = viewController else { logWarn("viewController is nil"); return }
                self.ocmController.wireframe?.showMainComponent(with: action, viewController: viewController)
            } else {
                let actionViewer = ActionViewer(action: action, ocmController: self.ocmController)
                guard let viewController = actionViewer.view() else { logWarn("view is nil"); return }
                self.ocmController.wireframe?.show(viewController: viewController)
            }
            
        case .deepLink:
            if action.preview != nil {
                guard let fromVC = viewController else { logWarn("viewController is nil"); return }
                self.ocmController.wireframe?.showMainComponent(with: action, viewController: fromVC)
            } else {
                self.execute(action: action)
            }
            
        case .banner:
            if action.preview != nil {
                guard let fromVC = viewController else { logWarn("viewController is nil"); return }
                self.ocmController.wireframe?.showMainComponent(with: action, viewController: fromVC)
            }
        }
    }
    
    func execute(action: Action) {
        
        switch action.actionType {
        case .article, .card, .content, .banner:
            // Do Nothing
            break
            
        case .scan:
            OrchextraWrapper.shared.startScanner()
            
        case .externalBrowser, .browser:
            self.launchOpenUrl(action, viewController: nil)
            
        case .webview:
            let actionViewer = ActionViewer(action: action, ocmController: self.ocmController)
            guard let viewController = actionViewer.view() else { logWarn("view is nil"); return }
            self.ocmController.wireframe?.show(viewController: viewController)
            
        case .video:
            let actionViewer = ActionViewer(action: action, ocmController: self.ocmController)
            guard let viewController = actionViewer.view() else { logWarn("view is nil"); return }
            self.ocmController.wireframe?.show(viewController: viewController)            
        case .deepLink:
            guard let actionCustomScheme = action as? ActionCustomScheme, let urlString = actionCustomScheme.url.string else { return }
            if actionCustomScheme.url.scheme != nil {
                self.ocmController.schemeDelegate?.openURLScheme(actionCustomScheme.url)
            } else {
                self.action(forcingDownload: false, with: urlString) { action, _ in
                    if action == nil {
                        self.ocmController.schemeDelegate?.openURLScheme(actionCustomScheme.url)
                    } else if let action = action {
                        self.run(action: action, viewController: UIApplication.topViewController())
                    }
                }
            }
        }
    }
    
    // MARK: Private Method
    
    private func launchOpenUrl(_ action: Action, viewController: UIViewController?) {
        var url: URL
        var federated: [String: Any]?
        var preview: Preview?
        
        if let actionParse = action as? ActionExternalBrowser {
            url = actionParse.url
            federated = actionParse.federated
            preview = actionParse.preview
        } else if let actionParse = action as? ActionBrowser {
            url = actionParse.url
            federated = actionParse.federated
            preview = actionParse.preview
        } else {
            logWarn("Miss necesary action for open url")
            return
        }
        
        if self.ocmController.isLogged {
            if let federatedData = federated, federatedData["active"] as? Bool == true {
                let federatedAction = action as? FederableAction
                federatedAction?.federateDelegate?.willStartFederatedAuthentication()
                self.ocmController.federatedAuthenticationDelegate?.federatedAuthentication(federatedData, completion: { params in
                    
                    federatedAction?.federateDelegate?.didFinishFederatedAuthentication()
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
            self.executeLaunch(action, viewController: viewController, url: url, preview: preview)
        }
    }
    
    private func executeLaunch(_ action: Action, viewController: UIViewController?, url: URL, preview: Preview?) {
        switch action.actionType {
        case .browser:
            self.launchAction(action, viewController: viewController, url: url, preview: preview)
        case .externalBrowser:
            UIApplication.shared.openURL(url)
        default:
            break
        }
    }
    
    private func launchAction(_ action: Action, viewController: UIViewController?, url: URL, preview: Preview?) {
        if preview != nil {
            guard let fromVC = viewController else {
                self.ocmController.wireframe?.showBrowser(url: url)
                return
            }
            self.ocmController.wireframe?.showMainComponent(with: action, viewController: fromVC)
        } else {
            self.ocmController.wireframe?.showBrowser(url: url)
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

//swiftlint:enable cyclomatic_complexity
