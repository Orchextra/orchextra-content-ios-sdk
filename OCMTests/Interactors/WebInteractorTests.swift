//
//  WebInteractorTests.swift
//  OCM
//
//  Created by Carlos Vicente on 12/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import XCTest
@testable import OCMSDK

class WebInteractorTests: XCTestCase {
    var webInteractor: WebInteractor!
    
    override func setUp() {
        super.setUp()
        _ = self.createPassBookWrapperMock()
    }
    
    override func tearDown() {
        self.webInteractor = nil
        super.tearDown()
    }
    
    // MARK: Helpers
    
    func createWebInteractor () {
        let passbookWrapper = self.createPassBookWrapperMock()
        self.webInteractor = WebInteractor(passbookWrapper: passbookWrapper)
    }
    
    func createPassBookWrapperMock() -> PassBookWrapperMock {
        let passBookWrapper = PassBookWrapperMock()
        return passBookWrapper
    }
    
    // MARK: Tests
    func testWebInteractorNotNil() {
        XCTAssertTrue(self.webInteractor != nil)
    }
    
}
