//
//  WidgetInteractorTests.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 9/8/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Quick
import Nimble
@testable import ZeusSDK


class WidgetInteractorSpec: QuickSpec {
	
	override func spec() {
		describe("a widgetInteractor") {
			var widgetInteractor: WidgetInteractor!
			var storage: Storage!
			var actionMock: ActionMock?
			
			beforeEach {
				storage = Storage()
				widgetInteractor = WidgetInteractor(storage: storage)
			}
			
			afterEach {
				storage = nil
				widgetInteractor = nil
			}
			
			sharedExamples("should do nothing") {
				it("") {
					expect(widgetInteractor.openWidget("TEST_WIDGET_1")).notTo(raiseException()) // Execute it without errors
				}
			}
			
			context("when storage has widgets") {
				beforeEach {
					storage.widgetList = WidgetHelper.WidgetObjectList()
					actionMock = storage.widgetList?.first?.action as? ActionMock
				}
				
				context("and widget is found in list") {
					beforeEach {
						widgetInteractor.openWidget("TEST_WIDGET_1")
					}
					
					it("should run the widget action") {
						expect(actionMock?.outRunCalled).to(beTrue())
					}
				}
				
				context("but widget is not found in list") {
					beforeEach {
						widgetInteractor.openWidget("TEST_WIDGET_20")
					}
					
					it("should not run the widget action") {
						expect(actionMock?.outRunCalled).toNot(beTrue())
					}
				}
			}
			
			context("when storage has empty list") {
				beforeEach {
					storage.widgetList = []
				}
				itBehavesLike("should do nothing")
			}
			
			context("when storage has no list") {
				beforeEach {
					storage.widgetList = nil
				}
				itBehavesLike("should do nothing")
			}
		}
	}
	
}

