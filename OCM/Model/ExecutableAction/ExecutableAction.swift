//
//  ActionExecution.swift
//  OCM
//
//  Created by José Estela on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

public protocol ExecutableAction {
    associatedtype ExecutableActionResponse
}

internal extension ExecutableAction {
    
    /// Method called when the action is executed
    ///
    /// - Parameter completion: Block to return the resulting response
    func perform(_ completion: @escaping (ExecutableActionResponse) -> Void) {}
}
