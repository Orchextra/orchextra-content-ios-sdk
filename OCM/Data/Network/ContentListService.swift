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
}


struct ContentListService: PContentListService {
    
    func getContentList(with path: String, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        let request = Request(
            method: "GET",
            baseUrl: Config.Host,
            endpoint: path,
            headers: Config.AppHeaders(),
            verbose: LogManager.shared.logLevel == .debug
        )
        
        request.fetchJson { response in
            switch response.status {
                
            case .success:
                do {
                    let json = try response.json()
                    let contentList = try ContentList.contentList(json)
                    Storage.shared.elementsCache = json["elementsCache"]

                    completionHandler(.success(contents: contentList))
					
                } catch {
                    let error = NSError.UnexpectedError("Error parsing json")
                    LogError(error)
                    
                    return completionHandler(.error(error: error))
                }
                
            default:
                let error = NSError.BasicResponseErrors(response)
                LogError(error)
                completionHandler(.error(error: error))
            }
        }
    }
    
}
