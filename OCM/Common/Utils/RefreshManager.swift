//
//  RefreshManager.swift
//  OCM
//
//  Created by José Estela on 28/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

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
    
    /// Method called when the data should be refreshed but only view cell not content
    func refreshViewCell()
}

extension Refreshable {
    func refreshViewCell() {}
}

class RefreshManager {
    
    // MARK: - Public attributes
    
    static let shared = RefreshManager()
    
    // MARK: - Private attributes
    
    private let reachability = ReachabilityWrapper.shared
    fileprivate var refreshables: [Refreshable] = []
    
    // MARK: - Private methods
    
    private init() {
        self.reachability.addDelegate(self)
    }
    
    deinit {
        self.reachability.removeDelegate(self)
    }
    
    // MARK: - Public methods
    
    func registerForNetworkChanges(_ refreshable: Refreshable) {
        if !self.refreshables.contains(where: { String(describing: $0) == String(describing: refreshable) }) {
            self.refreshables.append(refreshable)
        }
    }
    
    func unregisterForNetworkChanges(_ refreshable: Refreshable) {
        if let index = self.refreshables.index(where: { String(describing: $0) == String(describing: refreshable) }) {
            self.refreshables.remove(at: index)
        }
    }
    
    func refreshCell() {
        _ = self.refreshables.map({ refreshable in
            if refreshable.viewDataStatus != .loaded {
                refreshable.refreshViewCell()
            }
        })
    }
}

extension RefreshManager: ReachabilityWrapperDelegate {
    
    func reachabilityChanged(with status: NetworkStatus) {
        switch status {
        case .reachableViaWiFi, .reachableViaMobileData:
            _ = self.refreshables.map({ refreshable in
                if refreshable.viewDataStatus != .loaded {
                    refreshable.refresh()
                }
            })
        default:
            break
        }
    }
}
