//
//  MultiDelegable.swift
//  OCM
//
//  Created by  Eduardo Parada on 3/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol MultiDelegable: class {
    
    associatedtype Observer
    
    var observers: [WeakWrapper] { get set }
}

extension MultiDelegable {
    
    func add(observer: Observer) {
        if !self.observers.contains(where: { String(describing: $0.value ?? "" as AnyObject) == String(describing: observer) }) {
            self.observers.append(WeakWrapper(value: observer as AnyObject))
        } else {
            self.remove(observer: observer)
            self.observers.append(WeakWrapper(value: observer as AnyObject))
        }
    }
    
    func remove(observer: Observer) {
        if let index = self.observers.index(where: { String(describing: $0.value ?? "" as AnyObject) == String(describing: observer) }) {
            self.observers.remove(at: index)
        }
        self.observers = self.observers.flatMap({ $0.value != nil ? $0 : nil }) // Remove nil objects
    }
    
    func execute(_ selector: (Observer) -> Void) {
        for observer in self.observers {
            if let weak = observer.value as? Observer {
                selector(weak)
            }
        }
    }
}

class WeakWrapper {
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
}
