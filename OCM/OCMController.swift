//
//  OCMController.swift
//  OCM
//
//  Created by Eduardo Parada on 7/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import Orchextra

class OCMController {
    
    // Attributtes
    
    static let shared = OCMController()
    
    // MARK: Public var
    
    var eventDelegate: EventDelegate? {
        return OCM.shared.eventDelegate
    }
    
    var customBehaviourDelegate: CustomBehaviourDelegate? {
        return OCM.shared.customBehaviourDelegate
    }
    
    var contentDelegate: ContentDelegate? {
        return OCM.shared.contentDelegate
    }
    
    var federatedAuthenticationDelegate: FederatedAuthenticationDelegate? {
        return OCM.shared.federatedAuthenticationDelegate
    }
    
    var schemeDelegate: URLSchemeDelegate? {
        return OCM.shared.schemeDelegate
    }
    
    var customViewDelegate: CustomViewDelegate? {
        return OCM.shared.customViewDelegate
    }
    
    var errorDelegate: ErrorDelegate? {
        return OCM.shared.errorDelegate
    }
    
    var isLogged: Bool {
        return OCM.shared.isLogged
    }
    
    // MARK: - Private methods
    
    func start(apiKey: String, apiSecret: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        OrchextraWrapper.shared.startWith(apikey: apiKey, apiSecret: apiSecret, completion: completion)
        Config.isOrchextraRunning = true
    }
    
    func loadMenus() {
        ContentCoordinator.shared.loadMenus()
    }
    
    func performAction(with identifier: String, completion: @escaping (UIViewController?) -> Void) {
        let actionInteractor = ActionInteractor(
            contentDataManager: .sharedDataManager,
            ocmController: self,
            actionScheduleManager: ActionScheduleManager.shared
        )
        actionInteractor.action(forcingDownload: false, with: identifier, completion: { action, _ in
            if let action = action {
                if let video = action as? ActionVideo {
                    completion(ActionViewer(action: action, ocmController: OCMController.shared).view())
                    // Notify to eventdelegate that the video did load
                    OCM.shared.eventDelegate?.videoDidLoad(identifier: video.video.source)
                } else {
                    completion(self.wireframe?.loadMainComponent(with: action))
                    // Notify to eventdelegate that the content did open
                    if let elementUrl = action.elementUrl, !elementUrl.isEmpty {
                        OCM.shared.eventDelegate?.userDidOpenContent(identifier: elementUrl, type: action.type ?? "")
                    } else if let slug = action.slug, !slug.isEmpty {
                        OCM.shared.eventDelegate?.userDidOpenContent(identifier: slug, type: action.type ?? "")
                    }
                }
            } else {
                completion(nil)
            }
        })
    }
    
    func scan(_ completion: @escaping (ScannerResult?) -> Void) {
        OrchextraWrapper.shared.scan(completion: completion)
    }
    
    func resetCache() {
        ContentDataManager.sharedDataManager.cancelAllRequests()
        ContentCoreDataPersister.shared.cleanDataBase()
        ContentCacheManager.shared.resetCache()
    }
    
    func didLogin(with userID: String, completion: @escaping () -> Void) {
        Config.isLogged = true
        UserDefaultsManager.resetContentVersion()
        OrchextraWrapper.shared.bindUser(with: userID, completion: completion)
    }
    
    func didLogout(completion: @escaping () -> Void) {
        Config.isLogged = false
        UserDefaultsManager.resetContentVersion()
        OrchextraWrapper.shared.unbindUser(completion: completion) 
    }
    
    func removeLocalStorage() {
        WebviewLocalStorage.removeLocalStorage()
    }
    
    func applicationWillEnterForeground() {
        if ReachabilityWrapper.shared.isReachable() {
            ContentCoordinator.shared.loadMenus()
        }
    }
    
    // MARK: - Private & Internal
    
    internal var wireframe: OCMWireframe?
    
    func loadWireframe(wireframe: OCMWireframe) {
        self.wireframe = wireframe
        self.loadFonts()
    }
    
    func loadFonts() {
        UIFont.loadSDKFont(fromFile: "Gotham-Ultra.otf")
        UIFont.loadSDKFont(fromFile: "Gotham-Medium.otf")
        UIFont.loadSDKFont(fromFile: "Gotham-Light.otf")
        UIFont.loadSDKFont(fromFile: "Gotham-Book.otf")
    }
}
