//
//  ActionMock.swift
//  OCMTests
//
//  Created by José Estela on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

class ActionMock: Action {
    
    var identifier: String?
    var preview: Preview?
    var shareInfo: ShareInfo?
    var output: ActionOut?
    var spyViewCalled = false
    var actionView: OrchextraViewController?
    
    static func action(from json: JSON) -> Action? {
        return nil
    }
    
    func view() -> OrchextraViewController? {
        self.spyViewCalled = true
        return self.actionView
    }
}
