//
//  RefreshManager.swift
//  OCM
//
//  Created by José Estela on 28/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

enum ViewDataStatus {
    case loaded
    case notLoaded
    case canReload
}

protocol Refreshable {
    
    /// The view data status
    var viewDataStatus: ViewDataStatus { get }
    
    /// Method called when the data should be refreshed
    func refresh()
}

class RefreshManager: MultiDelegable {
    
    var observers: [WeakWrapper] = []
    typealias Observer = Refreshable
    
    // MARK: - Public attributes
    
    static let shared = RefreshManager()
    
    // MARK: - Private attributes
    
    private let reachability = ReachabilityWrapper.shared
    
    // MARK: - Private methods
    
    private init() {
        self.reachability.addDelegate(self)
    }
    
    deinit {
       self.reachability.removeDelegate(self)
    }
    
    // MARK: - Public methods
    
    func registerForNetworkChanges(_ refreshable: Refreshable) {
        self.add(observer: refreshable)
    }
    
    func unregisterForNetworkChanges(_ refreshable: Refreshable) {
        self.remove(observer: refreshable)
    }
}

extension RefreshManager: ReachabilityWrapperDelegate {
    
    func reachabilityChanged(with status: NetworkStatus) {
        switch status {
        case .reachableViaWiFi, .reachableViaMobileData:
            _ = self.observers.map({ refreshable in                
                let refresh = refreshable.value as? Refreshable
                if refresh?.viewDataStatus != .loaded {
                    refresh?.refresh()
                }
            })
        default:
            break
        }
    }
}
