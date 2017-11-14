//
//  MenuCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

protocol MenuCoordinatorProtocol: class {

    func loadMenus()
}

typealias MenusResult = (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void

class MenuCoordinator: MenuCoordinatorProtocol {
    
    // MARK: - Static public attributes
    
    static let shared = MenuCoordinator(
        sessionInteractor: SessionInteractor.shared,
        contentVersionInteractor: ContentVersionInteractor(contentDataManager: .sharedDataManager),
        menuInteractor: MenuInteractor(
            sessionInteractor: SessionInteractor.shared,
            contentDataManager: .sharedDataManager
        ),
        reachability: ReachabilityWrapper.shared
    )
    
    // MARK: - Public attributes
    
    var menus: [Menu]?
    
    // MARK: - Private attributes
    
    private let sessionInteractor: SessionInteractorProtocol
    private let contentVersionInteractor: ContentVersionInteractorProtocol
    private let menuInteractor: MenuInteractor
    private let reachability: ReachabilityWrapper
    private let menuQueue = DispatchQueue(label: "com.ocm.menu.downloadQueue", attributes: .concurrent)

    init(sessionInteractor: SessionInteractorProtocol, contentVersionInteractor: ContentVersionInteractorProtocol, menuInteractor: MenuInteractor, reachability: ReachabilityWrapper) {
        self.sessionInteractor = sessionInteractor
        self.contentVersionInteractor = contentVersionInteractor
        self.menuInteractor = menuInteractor
        self.reachability = reachability
    }
    
    // MARK: MenuCoordinatorProtocol
    
    func loadMenus() {
        if self.sessionInteractor.hasSession() {
            self.loadContentVersion()
        } else {
            self.sessionInteractor.loadSession { _ in
                self.loadContentVersion()
            }
        }
	}
	
	// MARK: - Private Helpers
    
    private func loadContentVersion() {
        
        self.contentVersionInteractor.loadContentVersion { (result) in
            switch result {
            case .success(let needsUpdate):
                // Menus will load synchronously, forcing an update
                self.loadMenusSynchronously(needsUpdate: needsUpdate)
            case .error(let error):
                //
                self.loadMenusSynchronously(needsUpdate: true)
                logError(error)
            }
        }
    }
	
    private func loadMenusSynchronously(needsUpdate: Bool) {
        
        self.menuInteractor.loadMenus(forceDownload: false) { (result, fromCache) in
            switch result {
            case .success(let menus):
                self.menus = menus
                OCM.shared.delegate?.menusDidRefresh(menus)
                if fromCache && needsUpdate {
                    self.loadMenusAsynchronously()
                }
            case .empty:
                self.menus = []
                OCM.shared.delegate?.menusDidRefresh([])
                if fromCache && needsUpdate {
                    self.loadMenusAsynchronously()
                }
            case .error(let message):
                self.menus = nil
                OCM.shared.delegate?.menusDidRefresh([])
                logInfo("ERROR: \(message)")
            }
        }
    }
    
    private func loadMenusAsynchronously() {
        
        guard Config.offlineSupport && self.reachability.isReachable() else { logWarn("is reacheable is nil"); return }
        self.menuQueue.async {
            self.menuInteractor.loadMenus(forceDownload: true) { result, _ in
                switch result {
                case .success(let menus):
                    if let unwrappedMenus = self.menus {
                        // Update only if there are changes
                        if unwrappedMenus != menus {
                            self.menus = menus
                            OCM.shared.delegate?.menusDidRefresh(menus)
                        }
                    } else {
                        // Update as there's no data
                        self.menus = menus
                        OCM.shared.delegate?.menusDidRefresh(menus)
                    }
                case .empty:
                    if let unwrappedMenus = self.menus {
                        // Update only if there are changes
                        if unwrappedMenus != [] {
                            self.menus = []
                            OCM.shared.delegate?.menusDidRefresh([])
                        }
                    } else {
                        // Update as there's no data
                        self.menus = []
                        OCM.shared.delegate?.menusDidRefresh([])
                    }
                case .error(let message):
                    // Ignore if there's an error
                    logInfo("ERROR: \(message)")
                }
            }
        }
    }
}
