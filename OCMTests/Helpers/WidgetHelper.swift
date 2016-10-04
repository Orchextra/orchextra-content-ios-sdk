//
//  WidgetHelper.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
@testable import ZeusSDK


class WidgetHelper {
    
    class func WidgetObject(id: Int = 1) -> Widget {
        return Widget(
            id: "TEST_WIDGET_\(id)",
            fullticket: false,
            media: Media(
                url: "MEDIA_URL_TEST"
            ),
            layout: .Carousel,
            action: ActionMock()
        )
        
    }
    
    class func WidgetObjectList() -> [Widget] {
        return (1...10).map(WidgetObject)
    }
    
}


class ActionMock: Action {
	
	var outRunCalled = false
	
	static func action(url: NSURLComponents) -> Action? {
		return ActionMock()
	}
	
	func run() {
		self.outRunCalled = true
	}
}


func ==(lhs: WidgetListResult, rhs: WidgetListResult) -> Bool {
    switch (lhs, rhs) {
    case (.Success(let widgetsLeft), .Success(let widgetsRight)) where widgetsLeft == widgetsRight: return true
    case (.Empty, .Empty): return true
    case (.Error(let messageLeft), .Error(let messageRight)) where messageLeft == messageRight: return true
        
    default: return false
    }
}


func ==(lhs: [Widget], rhs: [Widget]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    
    return lhs.reduce((result: true, index: 0)) { acumulator, widgetLeft in
        let widgetRight = rhs[acumulator.index]
        let step = acumulator.result && (widgetRight == widgetLeft)
        
        return (step, acumulator.index + 1)
        
    }.result
}


func ==(lhs: Widget, rhs: Widget) -> Bool {
    return lhs.id == rhs.id
}


extension Widget: CustomStringConvertible {
    
    var description: String {
        return "[ID: \(self.id)]"
    }
    
}
