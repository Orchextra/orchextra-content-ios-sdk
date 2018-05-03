//
//  ActionScheduleManager.swift
//  OCM
//
//  Created by José Estela on 31/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

typealias CustomPropertyAction = (customProperty: [String: Any]?, action: () -> Void)

class ActionScheduleManager {
    
    // MARK: - Public attributes
    
    static let shared = ActionScheduleManager()
    
    // MARK: - Private attributes
    
    private var actions: [CustomPropertyAction] = []
    
    // MARK: - Public methods
    
    func registerAction(for customProperty: [String: Any], action: @escaping () -> Void) {
        
        if let requiredAuth = customProperty["requiredAuth"] as? String, requiredAuth == "logged" {
            // Check if the user is logged before saving as a pending action
            if isLogged() {
                action()
            } else {
                self.actions.append((customProperty: customProperty, action: action))
            }
        } else {
            action()
        }
    }
    
    func removeActions(for customPropertyKey: String) {
        var auxActions: [([String: Any]?, () -> Void)] = []
        
        for action in self.actions where action.customProperty?[customPropertyKey] == nil {
            auxActions.append(action)
        }
        self.actions = auxActions
    }
    
    func performActions(for customPropertyKey: String) {
        self.actions
            .filter({ $0.customProperty?[customPropertyKey] != nil })
            .forEach({ $0.action() })
        
        self.removeActions(for: customPropertyKey)
    }
    
    // MARK: - Private methods
    
    private func isLogged() -> Bool {
        return Config.isLogged && OrchextraWrapper.shared.currentUser() != nil
            && OrchextraWrapper.shared.loadAccessToken() != nil
    }
}
