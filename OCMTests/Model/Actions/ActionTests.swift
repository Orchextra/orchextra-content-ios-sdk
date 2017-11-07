//
//  ActionTests.swift
//  OCMTests
//
//  Created by Eduardo Parada on 7/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import Quick
import Nimble
import GIGLibrary
@testable import OCMSDK

class ActionSpec: QuickSpec {
    
    // MARK: - Attributes
    var json: JSON!
    var identifier: String!
    
    override func spec() {
        beforeEach {
            self.identifier = "identifier"
        }
        
        afterEach {
            self.json = nil
        }
        
        describe("when parse a action") {
            beforeEach {
                self.json = JSON(from: [
                    "type": "webview",
                    "render":
                        [
                            "url": "http://url",
                            "federatedAuth": ["": ""]
                        ],
                    "share":
                        [
                            "url": "https://gigigo.com",
                            "text": "Text"
                        ],
                    "preview":
                        [
                            "type": "algo",
                            "imageUrl": "https://image.com",
                            "behaviour": "click"
                        ],
                    "slug": "slug"
                    ]
                )                
            }
            
            it("return a ActionWebview") {
                let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                expect(action?.elementUrl).toEventually(equal("identifier"))
                expect(action?.slug).toEventually(equal("slug"))
                expect(action?.type).toEventually(equal("webview"))
                expect(action?.shareInfo?.url).toEventually(equal("https://gigigo.com"))
                expect(action?.shareInfo?.text).toEventually(equal("Text"))
            }
        }
    }
}
