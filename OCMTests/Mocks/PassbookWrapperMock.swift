//
//  PassbookWrapperMock.swift
//  OCM
//
//  Created by Carlos Vicente on 12/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class PassBookWrapperMock: PassbookWrapperProtocol {
    var addPassbookMethodCalled: Bool = false
    var passbookWrapperResult: PassbookWrapperResult!
    
    func addPassbook(from url: String, completionHandler: @escaping (_ result: PassbookWrapperResult) -> Void) {
         self.addPassbookMethodCalled = true
    }
}
