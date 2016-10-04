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
    case success(contents: [Content])
    case error(error: NSError)
}


protocol PContentListService {
    func fetchContentList(maxWidth: Int, minWidth: Int, completionHandler: @escaping (WigetListServiceResult) -> Void)
}


class ContentListService: PContentListService {
    
    func fetchContentList(maxWidth: Int, minWidth: Int, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        let request = Request(
            method: "GET",
            baseUrl: Config.Host,
            endpoint: "/home/\(maxWidth)/\(minWidth)",
            headers: Config.AppHeaders(),
            verbose: LogManager.shared.logLevel == .debug
        )
        
        request.fetchJson { response in
            switch response.status {
                
            case .success:
                do {
                    let json = try response.json()
                    let contentList = try Content.contentList(json)
                    
                    completionHandler(.success(contents: contentList))
                }
                catch {
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
