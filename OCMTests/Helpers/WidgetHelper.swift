//
//  ContentHelper.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK


class ContentHelper {
    
    class func ContentObject(id: Int = 1) -> Content {
        return Content(
            id: "TEST_WIDGET_\(id)",
            fullticket: false,
            media: Media(
                url: "MEDIA_URL_TEST"
            ),
            layout: .carousel,
            action: ActionMock()
        )
        
    }
    
    class func ContentObjectList() -> [Content] {
        return (1...10).map(ContentObject)
    }
    
}


class ActionMock: Action {
	
	var outRunCalled = false
	
	static func action(_ url: URLComponents) -> Action? {
		return ActionMock()
	}
	
	func run() {
		self.outRunCalled = true
	}
}


func ==(lhs: ContentListResult, rhs: ContentListResult) -> Bool {
    switch (lhs, rhs) {
    case (.success(let contentsLeft), .success(let contentsRight)) where contentsLeft == contentsRight: return true
    case (.empty, .empty): return true
    case (.error(let messageLeft), .error(let messageRight)) where messageLeft == messageRight: return true
        
    default: return false
    }
}


func ==(lhs: [Content], rhs: [Content]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    
    return lhs.reduce((result: true, index: 0)) { acumulator, contentLeft in
        let contentRight = rhs[acumulator.index]
        let step = acumulator.result && (contentRight == contentLeft)
        
        return (step, acumulator.index + 1)
        
    }.result
}


func ==(lhs: Content, rhs: Content) -> Bool {
    return lhs.id == rhs.id
}


extension Content: CustomStringConvertible {
    
    var description: String {
        return "[ID: \(self.id)]"
    }
    
}
