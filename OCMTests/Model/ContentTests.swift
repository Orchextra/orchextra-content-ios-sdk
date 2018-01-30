//
//  ContentTests.swift
//  OCM
//
//  Created by Sergio López on 7/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import XCTest
@testable import OCMSDK

class ContentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_contentains_shouldReturnTrue_ifOneMatchingTag() {
        
        let content = Content(slug: "prueba",
                              tags: ["tag1", "tag2", "tag3"],
                              name: "title",
                              media: Media(url: nil, thumbnail: nil),
                              elementUrl: ".",
                              customProperties: [:],
                              dates: [])
        
        XCTAssert(content.contains(tags: ["tag1"]))
    }
    
    func test_contentains_shouldReturnTrue_ifTwoMatchingTags() {
        
        let content = Content(slug: "prueba",
                              tags: ["tag1", "tag2", "tag3"],
                              name: "title",
                              media: Media(url: nil, thumbnail: nil),
                              elementUrl: ".",
                              customProperties: [:],
                              dates: [])
        
        XCTAssert(content.contains(tags: ["tag1", "tag3"]))
    }
    
    func test_contentains_shouldReturnFalse_ifNonMatchingTags() {
        
        let content = Content(slug: "prueba",
                              tags: ["tag1", "tag2", "tag3"],
                              name: "title",
                              media: Media(url: nil, thumbnail: nil),
                              elementUrl: ".",
                              customProperties: [:],
                              dates: [])
        
        XCTAssert(content.contains(tags: ["tag4"]) == false)
    }
    
    func test_contentains_shouldReturnFalse_ifSomeNoMatchingTags() {
        
        let content = Content(slug: "prueba",
                              tags: ["tag1", "tag2", "tag3"],
                              name: "title",
                              media: Media(url: nil, thumbnail: nil),
                              elementUrl: ".",
                              customProperties: [:],
                              dates: [])
        
        XCTAssert(content.contains(tags: ["tag1", "tag4"]) == false)
    }
}
