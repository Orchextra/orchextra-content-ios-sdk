//
//  ReachabilityWrapper.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 26/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import Reachability

enum NetworkStatus {
    case notReachable
    case reachableViaWiFi
    case reachableViaMobileData
}

protocol ReachabilityWrapperDelegate: class {
    func reachabilityChanged(with status: NetworkStatus)
}

protocol ReachabilityInput {
    func isReachable() -> Bool
    func isReachableViaWiFi() -> Bool
}

class ReachabilityWrapper: MultiDelegable, ReachabilityInput {
    
    // MARK: - MultiDelegable
    
    typealias Observer = ReachabilityWrapperDelegate
    var observers: [WeakWrapper] = []
    
    // MARK: Singleton
    
    static let shared = ReachabilityWrapper()
    
    // MARK: Private properties
    
    private let reachability: Reachability?
    private var currentStatus = NetworkStatus.notReachable
    
    // MARK: - Life cycle
    private init() {
        
        self.reachability = Reachability()
        
        // Listen to reachability changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        self.currentStatus = self.networkStatus()
        
        try? self.reachability?.startNotifier()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .reachabilityChanged,
            object: reachability
        )
        
        self.reachability?.stopNotifier()
    }
    
    // MARK: - Reachability methods
    
    func isReachable() -> Bool {
        return self.reachability?.connection != Reachability.Connection.none
    }
    
    func isReachableViaWiFi() -> Bool {
        return self.reachability?.connection == .wifi
    }
    
    func addDelegate(_ delegate: ReachabilityWrapperDelegate) {
        self.add(observer: delegate)
    }
    
    func removeDelegate(_ delegate: ReachabilityWrapperDelegate) {
        self.remove(observer: delegate)
    }
    
    // MARK: - Private methods
    
    private func networkStatus() -> NetworkStatus {
        if let connection = self.reachability?.connection {
            switch connection {
            case .none:
                return .notReachable
            case .cellular:
                return .reachableViaMobileData
            case .wifi:
                return .reachableViaWiFi
            }
        }
        return .notReachable
    }
    
    // MARK: - Reachability Change
    
    @objc func reachabilityChanged(_ notification: NSNotification) {
        guard let reachability = notification.object as? Reachability else { return }
        if self.networkStatus() != self.currentStatus {
            self.currentStatus = self.networkStatus()
            if reachability.connection != Reachability.Connection.none {
                if reachability.connection == .wifi {
                    self.observers.flatMap({ $0.value as? ReachabilityWrapperDelegate }).forEach({ $0.reachabilityChanged(with: .reachableViaWiFi) })
                } else {
                    self.observers.flatMap({ $0.value as? ReachabilityWrapperDelegate }).forEach({ $0.reachabilityChanged(with: .reachableViaMobileData) })
                }
            } else {
                self.observers.flatMap({ $0.value as? ReachabilityWrapperDelegate }).forEach({ $0.reachabilityChanged(with: .notReachable) })
            }
        }
    }
}
