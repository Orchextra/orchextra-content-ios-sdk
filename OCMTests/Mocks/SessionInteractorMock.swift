//
//  SessionInteractorMock.swift
//  OCM
//
//  Created by José Estela on 14/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

class SessionInteractorMock: SessionInteractorProtocol {
    
    func hasSession() -> Bool {
        return true
    }

    func sessionExpired() {
        
    }

    func loadSession(completion: @escaping (Result<Bool, String>) -> Void) {
    
    }
}
