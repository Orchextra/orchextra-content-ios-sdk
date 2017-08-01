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
}

struct ContentListErrorServiceMock: ContentListServiceProtocol {
    
    func getContentList(with path: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        completionHandler(.error(NSError(domain: "", code: 0, message: "")))
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        
    }
    
}
