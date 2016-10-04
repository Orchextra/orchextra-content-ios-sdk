//
//  WidgetListInteractorTests.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import XCTest
@testable import ZeusSDK

class WidgetListInteractorTests: XCTestCase {
    
    var widgetListInteractor: WidgetListInteractor!
    var widgetListServiceMock: WidgetListServiceMock!
	var storage: Storage!
    
    
    override func setUp() {
        super.setUp()
		
		self.storage = Storage()
        self.widgetListServiceMock = WidgetListServiceMock()
        self.widgetListInteractor = WidgetListInteractor(
			service: self.widgetListServiceMock,
			storage: self.storage
		)
    }
    
    override func tearDown() {
        self.widgetListInteractor = nil
        self.widgetListServiceMock = nil
		self.storage = nil
        
        super.tearDown()
    }
    
    func test_not_nil() {
        XCTAssertNotNil(self.widgetListInteractor)
    }
    
    
    func tests_widgetList_returnsSuccessWithList_whenServiceReturnsSuccessWithList() {
        let widgets = WidgetHelper.WidgetObjectList()
        self.widgetListServiceMock.inResult = .Success(widgets: widgets)
        
        var completionCalled = false
        self.widgetListInteractor.widgetList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .Success(widgets: WidgetHelper.WidgetObjectList()), "result is \(result), but expected \(WidgetHelper.WidgetObjectList())")
            XCTAssert(self.widgetListServiceMock.outFetchWidgetList == (true, 300, 100))
			XCTAssert(self.storage.widgetList! == widgets)
        }
        
        XCTAssert(completionCalled == true)
    }
    
    
    func tests_widgetList_returnsEmpty_whenServiceReturnsSuccessWithEmptyList() {
        self.widgetListServiceMock.inResult = .Success(widgets: [])
        
        var completionCalled = false
        self.widgetListInteractor.widgetList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .Empty)
            XCTAssert(self.widgetListServiceMock.outFetchWidgetList == (true, 300, 100))
			XCTAssert(self.storage.widgetList! == [])
        }
        
        XCTAssert(completionCalled == true)
    }
    
    func tests_widgetList_returnsErrorWithCustomMessage_whenServiceReturnsErrorWithCustomMessage() {
        let error = NSError.CustomError(message: "TEST_MESSAGE")
        self.widgetListServiceMock.inResult = .Error(error: error)
        
        var completionCalled = false
        self.widgetListInteractor.widgetList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .Error(message: "TEST_MESSAGE"))
            XCTAssert(self.widgetListServiceMock.outFetchWidgetList == (true, 300, 100))
			XCTAssert(self.storage.widgetList == nil)
        }
        
        XCTAssert(completionCalled == true)
    }
    
    func tests_widgetList_returnsErrorWithUnexpectedMessage_whenServiceReturnsErrorUnexpected() {
        let error = NSError.UnexpectedError()
        self.widgetListServiceMock.inResult = .Error(error: error)
        
        var completionCalled = false
        self.widgetListInteractor.widgetList(maxWidth: 300, minWidth: 100) { result in
            completionCalled = true
            
            XCTAssert(result == .Error(message: NSError.UnexpectedError().errorMessage()))
            XCTAssert(self.widgetListServiceMock.outFetchWidgetList == (true, 300, 100))
			XCTAssert(self.storage.widgetList == nil)
        }
        
        XCTAssert(completionCalled == true)
    }
    
}
