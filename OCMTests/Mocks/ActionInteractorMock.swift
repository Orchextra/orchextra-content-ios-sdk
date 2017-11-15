//
//  ActionInteractorMock.swift
//  OCMTests
//
//  Created by José Estela on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class ActionInteractorMock: ActionInteractorProtocol {
    
    var completion: (action: Action?, error: Error?) = (nil, nil)
    
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        completion(self.completion.action, self.completion.error)
    }
}
