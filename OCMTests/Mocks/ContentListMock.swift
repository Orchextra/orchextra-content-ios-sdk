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

class ContentListEmpyContentServiceMock: ContentListServiceProtocol {
    
    func getContentList(with path: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        guard
            let file = Bundle(for: ContentListEmpyContentServiceMock.self).url(forResource: "contentlist_empty", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let json = try? JSON.dataToJson(data)
        else {
            completionHandler(.error(NSError.unexpectedError()))
            return
        }
        completionHandler(.success(json))
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        guard
            let file = Bundle(for: ContentListEmpyContentServiceMock.self).url(forResource: "contentlist_empty", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let json = try? JSON.dataToJson(data)
        else {
            completionHandler(.error(NSError.unexpectedError()))
            return
        }
        completionHandler(.success(json))
    }
    
    func cancelActiveRequest() {
        
    }
}

struct ContentListServiceMock: ContentListServiceProtocol {
    
    func getContentList(with path: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        guard
            let file = Bundle(for: ContentListEmpyContentServiceMock.self).url(forResource: "contentlist_ok", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let json = try? JSON.dataToJson(data)
        else {
            completionHandler(.error(NSError.unexpectedError()))
            return
        }
        completionHandler(.success(json))
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        guard
            let file = Bundle(for: ContentListEmpyContentServiceMock.self).url(forResource: "contentlist_ok", withExtension: "json"),
            let data = try? Data(contentsOf: file),
            let json = try? JSON.dataToJson(data)
        else {
            completionHandler(.error(NSError.unexpectedError()))
            return
        }
        completionHandler(.success(json))
    }
    
    func cancelActiveRequest() {
        
    }
}

class ContentListErrorServiceMock: ContentListServiceProtocol {
    
    // MARK: - Attributes
    
    var spyGetContentList = false
    var spyGetContentListSuccess: JSON!
    var spyGetContentListError: NSError!
 
    
    // MARK: - ContentListServiceProtocol
    
    func getContentList(with path: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        if self.spyGetContentListSuccess != nil {
            self.spyGetContentList = true
            completionHandler(.success(self.spyGetContentListSuccess))
        } else if self.spyGetContentListError != nil {
            self.spyGetContentList = true
            completionHandler(.error(self.spyGetContentListError))
        } else {
            completionHandler(.error(NSError(domain: "", code: 0, message: "")))
        }
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        
    }
    
    func cancelActiveRequest() {
        
    }
}
