//
//  ContentListMock.swift
//  OCM
//
//  Created by José Estela on 8/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

struct ContentListEmpyContentServiceMock: PContentListService {
    
    func getContentList(with path: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        let fakeLayoutDelegate = CarouselLayout()
        let fakeContentList = ContentList(contents: [], layout: fakeLayoutDelegate)
        completionHandler(.success(contents: fakeContentList))
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
    
    }
}

struct ContentListServiceMock: PContentListService {
    
    func getContentList(with path: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        let fakeLayoutDelegate = CarouselLayout()
        let fakeContentList = ContentList(
            contents: [
                Content(slug: "", tags: [], media: Media(url: "", thumbnail: nil), elementUrl: "", requiredAuth: "")
            ],
            layout: fakeLayoutDelegate
        )
        completionHandler(.success(contents: fakeContentList))
    } 

    func getContentList(matchingString: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        
    }
}

struct ContentListErrorServiceMock: PContentListService {
    
    func getContentList(with path: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        completionHandler(.error(error: NSError(domain: "", code: 0, message: "")))
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        
    }
}
