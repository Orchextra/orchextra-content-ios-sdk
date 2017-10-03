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

//swiftlint:disable class_delegate_protocol
protocol ReachabilityWrapperDelegate {
    func reachabilityChanged(with status: NetworkStatus)
}
//swiftlint:enable class_delegate_protocol

protocol ReachabilityInput {
    func isReachable() -> Bool
    func isReachableViaWiFi() -> Bool
}

class ReachabilityWrapper: ReachabilityInput {
    
    // MARK: Singleton
    static let shared = ReachabilityWrapper()
    
    // MARK: Private properties
    private let reachability: Reachability?
    private var delegates: [ReachabilityWrapperDelegate] = []
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
        return self.reachability?.connection != .none
    }
    
    func isReachableViaWiFi() -> Bool {
        return self.reachability?.connection == .wifi
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
            if reachability.connection != .none {
                if reachability.connection == .wifi {
                    _ = self.delegates.map({ $0.reachabilityChanged(with: .reachableViaWiFi) })
                } else {
                    _ = self.delegates.map({ $0.reachabilityChanged(with: .reachableViaMobileData) })
                }
            } else {
                _ = self.delegates.map({ $0.reachabilityChanged(with: .notReachable) })
            }
        }
    }
}
