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
        
        // MARK: -- WEBIEW --
        
        describe("when parse a action") {
            context("with json type webview") {
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
                    expect(action).toEventually(beAKindOf(ActionWebview.self))
                }
            }
            
            context("with json type webview and missing mandatory fields") {
                beforeEach {
                    self.json = JSON(from: [
                        "type": "webview"
                        ]
                    )
                }
                
                it("return Action banner") {
                    let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                    expect(action?.slug).toEventually(beNil())
                    expect(action?.type).toEventually(beNil())
                    expect(action?.shareInfo).toEventually(beNil())
                    expect(action?.preview).toEventually(beNil())
                    expect(ActionViewer(action: action!, ocmController: OCMController()).view()).toEventually(beNil())
                    expect(action).toEventually(beAKindOf(ActionBanner.self))
                }
            }
            
            // MARK: -- ARTICLE --

            describe("when parse a action") {
                context("with json type article") {
                    beforeEach {
                        self.json = JSON(from: [
                            "type": "article",
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
                    
                    it("return a ActionArticle") {
                        let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                        expect(action?.elementUrl).toEventually(equal("identifier"))
                        expect(action?.slug).toEventually(equal("slug"))
                        expect(action?.type).toEventually(equal("article"))
                        expect(action?.shareInfo?.url).toEventually(equal("https://gigigo.com"))
                        expect(action?.shareInfo?.text).toEventually(equal("Text"))
                        expect(action).toEventually(beAKindOf(ActionArticle.self))
                    }
                }
            }
            
            // MARK: -- BROWSER --
            
            describe("when parse a action") {
                context("with json type browser") {
                    beforeEach {
                        self.json = JSON(from: [
                            "type": "browser",
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
                    
                    it("return a ActionBrowser") {
                        let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                        expect(action?.elementUrl).toEventually(equal("identifier"))
                        expect(action?.slug).toEventually(equal("slug"))
                        expect(action?.type).toEventually(equal("browser"))
                        expect(action?.shareInfo?.url).toEventually(equal("https://gigigo.com"))
                        expect(action?.shareInfo?.text).toEventually(equal("Text"))
                        expect(action).toEventually(beAKindOf(ActionBrowser.self))
                    }
                }
            }
            
            // MARK: -- EXTERNAL BROWSER --
            
            describe("when parse a action") {
                context("with json type ActionExternalBrowser") {
                    beforeEach {
                        self.json = JSON(from: [
                            "type": "externalBrowser",
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
                    
                    it("return a ActionExternalBrowser") {
                        let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                        expect(action?.elementUrl).toEventually(equal("identifier"))
                        expect(action?.slug).toEventually(equal("slug"))
                        expect(action?.type).toEventually(equal("externalBrowser"))
                        expect(action?.shareInfo?.url).toEventually(equal("https://gigigo.com"))
                        expect(action?.shareInfo?.text).toEventually(equal("Text"))
                        expect(action).toEventually(beAKindOf(ActionExternalBrowser.self))
                    }
                }
            }
            
            // MARK: -- CARD --
            
            describe("when parse a action") {
                context("with json type articleCard") {
                    beforeEach {
                        self.json = JSON(from: [
                            "type": "articleCard",
                            "render":
                                [
                                    "url": "http://url",
                                    "federatedAuth": ["": ""],
                                    "elements": [
                                        [
                                            "elements": [
                                                [
                                                    "elements": [
                                                        ["": ""]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
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
                    
                    it("return a ActionCard") {
                        let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                        expect(action?.elementUrl).toEventually(equal("identifier"))
                        expect(action?.slug).toEventually(equal("slug"))
                        expect(action?.type).toEventually(equal("articleCard"))
                        expect(action?.shareInfo?.url).toEventually(equal("https://gigigo.com"))
                        expect(action?.shareInfo?.text).toEventually(equal("Text"))
                        expect(action).toEventually(beAKindOf(ActionCard.self))
                    }
                }
            }
            
            // MARK: -- VIDEO --
            
            describe("when parse a action") {
                context("with json type ActionVideo") {
                    beforeEach {
                        self.json = JSON(from: [
                            "type": "video",
                            "render":
                                [
                                    "url": "http://url",
                                    "federatedAuth": ["": ""],
                                    "format": "youtube",
                                    "source": "source"
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
                    
                    it("return a ActionVideo") {
                        let action = ActionFactory.action(from: self.json, identifier: self.identifier)
                        expect(action?.elementUrl).toEventually(equal("identifier"))
                        expect(action?.slug).toEventually(equal("slug"))
                        expect(action?.type).toEventually(equal("video"))
                        expect(action?.shareInfo?.url).toEventually(equal("https://gigigo.com"))
                        expect(action?.shareInfo?.text).toEventually(equal("Text"))
                        expect(action).toEventually(beAKindOf(ActionVideo.self))
                    }
                }
            }
        }
    }
}
