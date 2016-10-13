//
//  ContentInteractorTests.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 9/8/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Quick
import Nimble
@testable import OCMSDK


class ContentInteractorSpec: QuickSpec {
	
	override func spec() {
		describe("a contentInteractor") {
			var contentInteractor: ContentInteractor!
			var storage: Storage!
			var actionMock: ActionMock?
			
			beforeEach {
				storage = Storage()
				contentInteractor = ContentInteractor(storage: storage)
			}
			
			afterEach {
				storage = nil
				contentInteractor = nil
			}
			
			sharedExamples("should do nothing") {
				it("") {
					expect(contentInteractor.openContent("TEST_WIDGET_1")).notTo(raiseException()) // Execute it without errors
				}
			}
			
			context("when storage has contents") {
				beforeEach {
					storage.contentList = ContentHelper.ContentObjectList()
					actionMock = storage.contentList?.first?.action as? ActionMock
				}
				
				context("and content is found in list") {
					beforeEach {
						contentInteractor.openContent("TEST_WIDGET_1")
					}
					
					it("should run the content action") {
						expect(actionMock?.outRunCalled).to(beTrue())
					}
				}
				
				context("but content is not found in list") {
					beforeEach {
						contentInteractor.openContent("TEST_WIDGET_20")
					}
					
					it("should not run the content action") {
						expect(actionMock?.outRunCalled).toNot(beTrue())
					}
				}
			}
			
			context("when storage has empty list") {
				beforeEach {
					storage.contentList = []
				}
				itBehavesLike("should do nothing")
			}
			
			context("when storage has no list") {
				beforeEach {
					storage.contentList = nil
				}
				itBehavesLike("should do nothing")
			}
		}
	}
	
}
