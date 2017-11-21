//
//  ElementServiceMock.swift
//  OCMTests
//
//  Created by Eduardo Parada on 7/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

class ElementServiceMock: ElementServiceInput {
    
    var error: NSError?
    var action: Action?
    
    func getElement(with identifier: String, completion: @escaping (Result<Action, NSError>) -> Void) {
        
        if let action = self.action {
            completion(.success(action))
        } else if let error = self.error {
            completion(.error(error))
        } else {
            completion(.error(NSError(domain: "BadError", code: -1, message: "Atention doesn't send action or error")))
        }
    }
}
