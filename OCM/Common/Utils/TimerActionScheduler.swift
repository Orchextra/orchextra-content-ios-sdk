//
//  TimerActionScheduler.swift
//  OCM
//
//  Created by José Estela on 1/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

private class TimeredAction: Equatable, Hashable, CustomStringConvertible {
    
    let identifier: String
    let maxSeconds: TimeInterval
    let action: () -> Void
    var startTime: Date?
    var hashValue: Int {
        return self.identifier.hashValue
    }
    var description: String {
        return "\(self.identifier): MaxSeconds: \(self.maxSeconds)"
    }
    
    init(identifier: String, maxSeconds: TimeInterval, action: @escaping () -> Void) {
        self.identifier = identifier
        self.maxSeconds = maxSeconds
        self.action = action
    }
    
    static func == (lhs: TimeredAction, rhs: TimeredAction) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class TimerActionScheduler {
    
    // MARK: - Public attributes
    
    static let shared = TimerActionScheduler()
    
    // MARK: - Private attributes
    
    private var actions: Set<TimeredAction> = Set()
    
    // MARK: - Public methods
    
    func registerAction(identifier: String, executeAfter seconds: TimeInterval, action: @escaping () -> Void) {
        self.actions.insert(TimeredAction(identifier: identifier, maxSeconds: seconds, action: action))
    }
    
    func start(_ identifier: String) {
        guard let index = self.actions.index(where: { $0.identifier == identifier }) else { return LogWarn("There isn't any action with this identifier saved") }
        self.actions[index].startTime = Date()
    }
    
    func stop(_ identifier: String) {
        guard let index = self.actions.index(where: { $0.identifier == identifier }), let startTime = self.actions[index].startTime else { return LogWarn("There isn't any action with this identifier saved \(self.actions)") }
        let action = self.actions[index]
        let currentTime = Date().timeIntervalSince1970
        if (currentTime - startTime.timeIntervalSince1970) <= action.maxSeconds {
            action.action()
        }
        self.actions.remove(at: index)
    }
}
