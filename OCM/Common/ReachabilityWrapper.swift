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

class ReachabilityWrapper {
    
    // MARK: Singleton
    static let shared = ReachabilityWrapper()
    
    // MARK: Private properties
    let reachability: Reachability?
    
    // MARK: - Life cycle
    private init() {
        
        self.reachability = Reachability()
        
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
    func startNotifier() throws {
        try self.reachability?.startNotifier()
    }
    
    func stopNotifier() {
        self.reachability?.stopNotifier()
    }
    
    func isReachable() -> Bool {
        return self.reachability?.isReachable ?? false
    }
    
    func isReachableViaWiFi() -> Bool {
        return self.reachability?.isReachableViaWiFi ?? false
    }
    
    // MARK: - Reachability Change
    
    @objc func reachabilityChanged(_ notification: NSNotification) {
        
//        guard let reachability = notification.object as? Reachability else { return }
//        
//        if reachability.isReachable {
//            if reachability.isReachableViaWiFi {
//                
//            } else {
//                // Stop caching process when in 3G, 4G, etc.
//                self.pauseCaching()
//            }
//        }
    }
}
