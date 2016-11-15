//
//  ContentListServices.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


enum WigetListServiceResult {
    case success(contents: ContentList)
    case error(error: NSError)
}


protocol PContentListService {
	func getContentList(with path: String, completionHandler: @escaping (WigetListServiceResult) -> Void)
    func getContentList(matchingString: String, completionHandler: @escaping (WigetListServiceResult) -> Void)
}


struct ContentListService: PContentListService {
    
    func getContentList(with path: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: path
        )
        
        request.fetch { response in
            switch response.status {
                
            case .success:
                do {
                    let json = try response.json()
                    let contentList = try ContentList.contentList(json)
                    Storage.shared.appendElementsCache(elements: json["elementsCache"])

                    completionHandler(.success(contents: contentList))
					
                } catch {
                    let error = NSError.UnexpectedError("Error parsing json")
                    LogError(error)
                    
                    return completionHandler(.error(error: error))
                }
                
            default:
                let error = NSError.OCMBasicResponseErrors(response)
                LogError(error)
                completionHandler(.error(error: error))
            }
        }
    }
    
    func getContentList(matchingString: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        self.getContentList(with: "/content/582b2e0b3bf88dd67bfd666b") { (wigetListServiceResult) in
            completionHandler(wigetListServiceResult)
        }
    }
}
