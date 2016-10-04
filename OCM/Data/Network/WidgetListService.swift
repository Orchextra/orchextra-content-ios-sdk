//
//  WidgetListServices.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


enum WigetListServiceResult {
    case Success(widgets: [Widget])
    case Error(error: NSError)
}


protocol PWidgetListService {
    func fetchWidgetList(maxWidth maxWidth: Int, minWidth: Int, completionHandler: WigetListServiceResult -> Void)
}


class WidgetListService: PWidgetListService {
    
    func fetchWidgetList(maxWidth maxWidth: Int, minWidth: Int, completionHandler: WigetListServiceResult -> Void) {
        let request = Request(
            method: "GET",
            baseUrl: Config.Host,
            endpoint: "/home/\(maxWidth)/\(minWidth)",
            headers: Config.AppHeaders(),
            verbose: LogManager.shared.logLevel == .Debug
        )
        
        request.fetchJson { response in
            switch response.status {
                
            case .Success:
                do {
                    let json = try response.json()
                    let widgetList = try Widget.widgetList(json)
                    
                    completionHandler(.Success(widgets: widgetList))
                }
                catch {
                    let error = NSError.UnexpectedError("Error parsing json")
                    LogError(error)
                    
                    return completionHandler(.Error(error: error))
                }
                
            default:
                let error = NSError.BasicResponseErrors(response)
                LogError(error)
                completionHandler(.Error(error: error))
            }
        }
    }
    
}
