//
//  ContentListInteractorTests.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import XCTest
@testable import OCMSDK

class ContentListInteractorTests: XCTestCase {
    
    var contentListInteractor: ContentListInteractor!
    var contentListServiceMock: ContentListServiceMock!
	var storage: Storage!
    
    
    override func setUp() {
        super.setUp()
		
		self.storage = Storage()
        self.contentListServiceMock = ContentListServiceMock()
        self.contentListInteractor = ContentListInteractor(
			service: self.contentListServiceMock,
			storage: self.storage
		)
    }
    
    override func tearDown() {
        self.contentListInteractor = nil
        self.contentListServiceMock = nil
		self.storage = nil
        
        super.tearDown()
    }
    
    func test_not_nil() {
        XCTAssertNotNil(self.contentListInteractor)
    }
    
    
    func tests_contentList_returnsSuccessWithList_whenServiceReturnsSuccessWithList() {
        let contents = ContentHelper.ContentObjectList()
        self.contentListServiceMock.inResult = .success(contents: contents)
        
        var completionCalled = false
        self.contentListInteractor.contentList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .success(contents: ContentHelper.ContentObjectList()), "result is \(result), but expected \(ContentHelper.ContentObjectList())")
            XCTAssert(self.contentListServiceMock.outFetchContentList == (true, 300, 100))
			XCTAssert(self.storage.contentList! == contents)
        }
        
        XCTAssert(completionCalled == true)
    }
    
    
    func tests_contentList_returnsEmpty_whenServiceReturnsSuccessWithEmptyList() {
        self.contentListServiceMock.inResult = .success(contents: [])
        
        var completionCalled = false
        self.contentListInteractor.contentList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .empty)
            XCTAssert(self.contentListServiceMock.outFetchContentList == (true, 300, 100))
			XCTAssert(self.storage.contentList! == [])
        }
        
        XCTAssert(completionCalled == true)
    }
    
    func tests_contentList_returnsErrorWithCustomMessage_whenServiceReturnsErrorWithCustomMessage() {
        let error = NSError.CustomError(message: "TEST_MESSAGE")
        self.contentListServiceMock.inResult = .error(error: error)
        
        var completionCalled = false
        self.contentListInteractor.contentList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .error(message: "TEST_MESSAGE"))
            XCTAssert(self.contentListServiceMock.outFetchContentList == (true, 300, 100))
			XCTAssert(self.storage.contentList == nil)
        }
        
        XCTAssert(completionCalled == true)
    }
    
    func tests_contentList_returnsErrorWithUnexpectedMessage_whenServiceReturnsErrorUnexpected() {
        let error = NSError.UnexpectedError()
        self.contentListServiceMock.inResult = .error(error: error)
        
        var completionCalled = false
        self.contentListInteractor.contentList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .error(message: NSError.UnexpectedError().errorMessage()))
            XCTAssert(self.contentListServiceMock.outFetchContentList == (true, 300, 100))
			XCTAssert(self.storage.contentList == nil)
        }
        
        XCTAssert(completionCalled == true)
    }
    
}
