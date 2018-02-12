//
//  OCMController.swift
//  OCM
//
//  Created by Eduardo Parada on 7/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

class OCMController {
    
    // Attributtes
    
    static let shared = OCMController()
    
    // MARK: Public var
    
    
    var eventDelegate: OCMEventDelegate? {
        return OCM.shared.eventDelegate
    }
    
    var customBehaviourDelegate: OCMCustomBehaviourDelegate? {
        return OCM.shared.customBehaviourDelegate
    }
    
    var delegate: OCMDelegate? {
        return OCM.shared.delegate
    }
    
    var isLogged: Bool {
        return OCM.shared.isLogged
    }
    
    // MARK: Public method
    
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
            ocm: OCMController.shared,
            actionScheduleManager: ActionScheduleManager.shared
        )
        actionInteractor.action(forcingDownload: false, with: identifier, completion: { action, _ in
            if let action = action {
                if let video = action as? ActionVideo {
                    completion(ActionViewer(action: action, ocm: OCMController.shared).view())
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
    
    func scan(_ completion: @escaping(String?) -> Void) {
        OrchextraWrapper.shared.scan(completion: completion)
    }
    
    func update(localStorage: [AnyHashable: Any]?) {
        Session.shared.localStorage = localStorage
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
        OrchextraWrapper.shared.bindUser(with: nil, completion: completion)
    }
    
    func searchViewController() -> OrchextraViewController? {
        return self.wireframe?.loadContentList(from: nil)
    }
    
    func isResetLocalStorageWebView(reset: Bool) {
        Config.resetLocalStorageWebView = reset
    }
    
    func applicationWillEnterForeground() {
        ContentCoordinator.shared.loadVersion()
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
