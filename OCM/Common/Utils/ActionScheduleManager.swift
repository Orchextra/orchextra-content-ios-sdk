//
//  ActionScheduleManager.swift
//  OCM
//
//  Created by José Estela on 31/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

typealias EventAction = (event: ActionScheduleEvent, action: () -> Void)

enum ActionScheduleEvent {
    case login
    case logout
}

class ActionScheduleManager {
    
    // MARK: - Public attributes
    
    static let shared = ActionScheduleManager()
    
    // MARK: - Private attributes
    
    private var actions: [EventAction] = []
    
    // MARK: - Public methods
    
    func registerAction(for event: ActionScheduleEvent, action: @escaping () -> Void) {
        self.actions.append((event: event, action: action))
    }
    
    func removeActions(for event: ActionScheduleEvent) {
        for (index, action) in self.actions.enumerated() where action.event == event {
            self.actions.remove(at: index)
        }
    }
    
    func performActions(for event: ActionScheduleEvent) {
        self.actions
            .filter({ $0.event == event })
            .forEach({ $0.action() })
        for (index, action) in self.actions.enumerated() where action.event == event {
            self.actions.remove(at: index)
        }
    }
}
