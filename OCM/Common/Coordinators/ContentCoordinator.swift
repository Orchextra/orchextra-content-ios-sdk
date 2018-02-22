//
//  ContentCoordinator.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ContentCoordinatorProtocol: class {
    func loadMenus()
    //func loadVersion()
    //func loadVersionForContentUpdate(contentPath: String)
    func addObserver(_ observer: ContentListInteractorProtocol)
    func removeObserver(_ observer: ContentListInteractorProtocol)
}

typealias MenusResult = (_ succeed: Bool, _ menus: [Menu], _ error: NSError?) -> Void

class ContentCoordinator: MultiDelegable {
    
    // MARK: - Static public attributes
    
    static let shared = ContentCoordinator(
        sessionInteractor: SessionInteractor.shared,
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
    private let menuInteractor: MenuInteractor
    private let reachability: ReachabilityWrapper
    private let menuQueue = DispatchQueue(label: "com.ocm.menu.downloadQueue", attributes: .concurrent)
    
    // MARK: - MultiDelegable
    
    typealias Observer = ContentListInteractorProtocol
    var observers: [WeakWrapper] = []

    // MARK: - Initializer
    
    init(sessionInteractor: SessionInteractorProtocol, menuInteractor: MenuInteractor, reachability: ReachabilityWrapper) {
        self.sessionInteractor = sessionInteractor
        self.menuInteractor = menuInteractor
        self.reachability = reachability
    }
	
	// MARK: - Private Helpers
        
    fileprivate func loadMenusSynchronously() {
        self.menuInteractor.loadMenus(forceDownload: false) { (result, _) in
            switch result {
            case .success(let menus):
                self.menus = menus
                OCM.shared.delegate?.menusDidRefresh(menus)
            case .empty:
                self.menus = []
                OCM.shared.delegate?.menusDidRefresh([])
            case .error(let message):
                self.menus = nil
                OCM.shared.delegate?.menusDidRefresh([])
                logInfo("ERROR: \(message)")
            }
        }
    }
    
    fileprivate func loadMenusAsynchronously() {
        guard Config.offlineSupportConfig != nil else { logWarn("No Internet reacheable"); return }
        self.menuQueue.async {
            self.menuInteractor.loadMenus(forceDownload: true) { result, _ in
                switch result {
                case .success(let menus):
                    if let unwrappedMenus = self.menus {
                        if unwrappedMenus != menus {
                            // Notify menus changed
                            self.menus = menus
                            OCM.shared.delegate?.menusDidRefresh(menus)
                        }
                        // Reload sections
                        self.execute({ $0.contentList(forcingDownload: true) })
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
    
    fileprivate func loadMenusAsynchronouslyForContentUpdate(contentPath: String) {
        
        guard Config.offlineSupportConfig != nil else { logWarn("No Internet reacheable"); return }
        self.menuQueue.async {
            self.menuInteractor.loadMenus(forceDownload: true) { result, _ in
                switch result {
                case .success(let menus):
                    if let unwrappedMenus = self.menus {
                        if unwrappedMenus != menus {
                            // Reload section being displayed
                            self.loadContentList(contentPath: contentPath, forcingDownload: true)
                            // Notify menus changed
                            self.menus = menus
                            OCM.shared.delegate?.menusDidRefresh(menus)
                        } else {
                            // Reload sections
                            self.execute({ $0.contentList(forcingDownload: true) })
                        }
                    } else {
                        // Notify content update finished and that menus changed
                        self.loadContentList(contentPath: contentPath, forcingDownload: true)
                        self.menus = menus
                        OCM.shared.delegate?.menusDidRefresh(menus)
                    }
                case .empty:
                    // Notify content update finished
                    self.loadContentList(contentPath: contentPath, forcingDownload: true)
                    if let unwrappedMenus = self.menus {
                        if unwrappedMenus != [] {
                            self.menus = []
                            OCM.shared.delegate?.menusDidRefresh([])
                        }
                    } else {
                        self.menus = []
                        OCM.shared.delegate?.menusDidRefresh([])
                    }
                case .error(let message):
                    // Notify content update finished
                    logInfo("ERROR: \(message)")
                    self.loadContentList(contentPath: contentPath, forcingDownload: true)
                }
            }
        }
    }
    
    // MARK: - Helpers
    func loadContentList(contentPath: String, forcingDownload: Bool) {
        self.execute({
            if $0.associatedContentPath() == contentPath {
                $0.contentList(forcingDownload: forcingDownload)
            }
        })
    }
}

// MARK: - ContentCoordinatorProtocol

extension ContentCoordinator: ContentCoordinatorProtocol {
    
    func loadMenus() {
        // Load menus from cache
        self.loadMenusSynchronously()
        if Config.offlineSupportConfig != nil {
            // Load menus asynchronously, forcing an update
            self.loadMenusAsynchronously()
        }
    }
    
    func addObserver(_ observer: ContentListInteractorProtocol) {
        self.add(observer: observer)
    }
    
    func removeObserver(_ observer: ContentListInteractorProtocol) {
        self.remove(observer: observer)
    }
}
