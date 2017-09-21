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
    var passBookWrapper: PassBookWrapperMock!
    
    static let validPassbookUrlAlwaysOnFormat = "https://alwayson.q.orchextra.io/campaign/OmPjLMprozC6QRaX2bYX/coupon/ra65jQ6vx3s5e12JO7E8/passbook"
    
    static let validPassbookUrlPkpassFormat = "https://alwayson.q.orchextra.io/campaign/OmPjLMprozC6QRaX2bYX/coupon/ra65jQ6vx3s5e12JO7E8/passbook.pkpass"
    
    static let invalidPassbookUrl = "https://alwayson.q.orchextra.io/campaign/OmPjLMprozC6QRaX2bYX/coupon/ra65jQ6vx3s5e12JO7E8"
    
     static let invalidCampaignUrl = "https://alwayson.q.orchextra.io/campaign/OmPjLMprozC6QRaX2bYX/coupon/ra65jQ6vx3s5e12JO7E8/passbook"
    
    override func setUp() {
        super.setUp()
        self.createWebInteractor()
    }
    
    override func tearDown() {
        self.webInteractor = nil
        super.tearDown()
    }
    
    // MARK: Helpers
    func createWebInteractor () {
        let passbookWrapper = self.createPassBookWrapperMock()
        self.passBookWrapper = passbookWrapper
        self.webInteractor = WebInteractor(
            passbookWrapper: passbookWrapper, federated: ["sso_token": "U2FsdGVkX1+zsyT1ULUqZZoAd/AANGnkQExYsAnzFlY5/Ff/BCkaSSuhR0/xvy0e"])
    }
    
    func createPassBookWrapperMock() -> PassBookWrapperMock {
        let passBookWrapper = PassBookWrapperMock()
        return passBookWrapper
    }
    
    // MARK: Tests
    func test_web_interactor_not_nil() {
        XCTAssertTrue(self.webInteractor != nil)
    }
    
    func test_passbook_url_with_valid_always_on_format() {
        let validPassbookUrlAlwaysOnFormat: URL = URL(string: WebInteractorTests.validPassbookUrlAlwaysOnFormat)!
        XCTAssertTrue(webInteractor.urlHasValidPassbookFormat(url: validPassbookUrlAlwaysOnFormat))
    }
    
    func test_passbook_url_with_valid_pkpass_format() {
        let validPassbookUrlPkpassFormat: URL = URL(string: WebInteractorTests.validPassbookUrlPkpassFormat)!
        XCTAssertTrue(webInteractor.urlHasValidPassbookFormat(url: validPassbookUrlPkpassFormat))
    }
    
    func test_passbook_url_with_invalid_format() {
        let invalidPassbookUrl: URL = URL(string: WebInteractorTests.invalidPassbookUrl)!
        XCTAssertFalse(webInteractor.urlHasValidPassbookFormat(url: invalidPassbookUrl))
    }
    
    func test_passbook_url_with_invalid_campaign_url() {
        let invalidCampaignUrl: URL = URL(string: WebInteractorTests.invalidCampaignUrl)!
        let errorTest = NSError(domain: "Domain example", code: 100, userInfo: nil)
        let result = PassbookWrapperResult.error(errorTest)
        self.passBookWrapper.passbookWrapperResult = result
        self.webInteractor.userDidProvokeRedirection(with: invalidCampaignUrl) { _ in
            XCTAssertTrue(self.passBookWrapper.addPassbookMethodCalled)
        }
        let isSuccess = (result == .success)
        let isError = (result == .error(errorTest))
        let isErrorUnsupportedVersion = (result == .unsupportedVersionError(errorTest))
        XCTAssertFalse(isSuccess)
        XCTAssertTrue(isError)
        XCTAssertFalse(isErrorUnsupportedVersion)
    }
    
    func test_passbook_url_with_valid_campaign_url() {
        let validCampaignUrl: URL = URL(string: WebInteractorTests.validPassbookUrlAlwaysOnFormat)!
        let result = PassbookWrapperResult.success
        let errorTest = NSError(domain: "Domain example", code: 100, userInfo: nil)
        self.passBookWrapper.passbookWrapperResult = result
        self.webInteractor.userDidProvokeRedirection(with: validCampaignUrl) { _ in
            XCTAssertTrue(self.passBookWrapper.addPassbookMethodCalled)
        }
        let isSuccess = (result == .success)
        let isError = (result == .error(errorTest))
        let isErrorUnsupportedVersion = (result == .unsupportedVersionError(errorTest))
        XCTAssertTrue(isSuccess)
        XCTAssertFalse(isError)
        XCTAssertFalse(isErrorUnsupportedVersion)

    }
    
}
