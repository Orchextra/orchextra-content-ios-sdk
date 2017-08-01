//
//  ReachabilityWrapper.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 26/06/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import Reachability

enum NetworkStatus {
    case notReachable
    case reachableViaWiFi
    case reachableViaMobileData
}

protocol ReachabilityWrapperDelegate: class {
    func reachabilityChanged(with status: NetworkStatus)
}

class ReachabilityWrapper {
    
    // MARK: Singleton
    static let shared = ReachabilityWrapper()
    
    // MARK: Private properties
    private let reachability: Reachability?
    private var delegates: [ReachabilityWrapperDelegate] = []
    
    // MARK: - Life cycle
    private init() {
        
        self.reachability = Reachability()
        try? self.startNotifier()
        
        // Listen to reachability changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: ReachabilityChangedNotification,
            object: reachability
        )
    }
    
    deinit {
        
        self.stopNotifier()
        
        NotificationCenter.default.removeObserver(
            self,
            name: ReachabilityChangedNotification,
            object: reachability)
    }
    
    // MARK: - Reachability methods
    
    func isReachable() -> Bool {
        return self.reachability?.isReachable ?? false
    }
    
    func isReachableViaWiFi() -> Bool {
        return self.reachability?.isReachableViaWiFi ?? false
    }
    
    func addDelegate(_ delegate: ReachabilityWrapperDelegate) {
        if !self.delegates.contains(where: { String(describing: $0) == String(describing: delegate) }) {
            self.delegates.append(delegate)
        }
    }
    
    func removeDelegate(_ delegate: ReachabilityWrapperDelegate) {
        if let index = self.delegates.index(where: { String(describing: $0) == String(describing: delegate) }) {
            self.delegates.remove(at: index)
        }
    }
    
    // MARK: - Private methods
    
    private func startNotifier() throws {
        try self.reachability?.startNotifier()
    }
    
    private func stopNotifier() {
        self.reachability?.stopNotifier()
    }
    
    // MARK: - Reachability Change
    
    @objc func reachabilityChanged(_ notification: NSNotification) {
        guard let reachability = notification.object as? Reachability else { return }
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                _ = self.delegates.map({ $0.reachabilityChanged(with: .reachableViaWiFi) })
            } else {
                _ = self.delegates.map({ $0.reachabilityChanged(with: .reachableViaMobileData) })
            }
        } else {
            _ = self.delegates.map({ $0.reachabilityChanged(with: .notReachable) })
        }
    }
}
