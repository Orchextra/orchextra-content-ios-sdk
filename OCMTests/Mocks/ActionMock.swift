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
        
    var slug: String?
    var elementUrl: String?
    var customProperties: [String : Any]?
    var type: String?
    var identifier: String?
    var preview: Preview?
    var shareInfo: ShareInfo?
    var spyViewCalled = false
    var actionView: UIViewController?
    var actionType: ActionType
    
    init(actionType: ActionType) {
        self.actionType = actionType
    }
    
    static func action(from json: JSON) -> Action? {
        return nil
    }
    
    func view() -> UIViewController? {
        self.spyViewCalled = true
        return self.actionView
    }
}
