//
//  ReachabilityMock.swift
//  OCMTests
//
//  Created by José Estela on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class ReachabilityMock: ReachabilityInput {
    
    var mockIsReachable = false
    var mockIsReachableViaWiFi = false
    
    // MARK: - ReachabilityInput
    
    func isReachable() -> Bool {
        return self.mockIsReachable
    }
    
    func isReachableViaWiFi() -> Bool {
        return self.mockIsReachableViaWiFi
    }
    
}
