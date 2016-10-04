//
//  NSError+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


let BundleIdentifier        = "com.orchextra.ocm"
let ErrorMessageKey         = "OCM_ERROR_MESSAGE"
let ErrorDebugMessageKey    = "OCM_ERROR_DEBUG_MESSAGE"


extension NSError {
    
    class func CustomError(message message: String? = nil, debugMessage: String? = nil, baseError: NSError? = nil) -> NSError {
        var userInfo: [NSObject: AnyObject] = baseError?.userInfo ?? [:]
        let code = baseError?.code ?? -1
        
        if message != nil {
            userInfo[ErrorMessageKey] = message!
        }
        
        if debugMessage != nil {
            userInfo[ErrorDebugMessageKey] = debugMessage!
        }
        
        return NSError(domain: BundleIdentifier, code: code, userInfo: userInfo)
    }
    
    class func UnexpectedError(debugMessage: String? = nil) -> NSError {
        return NSError.CustomError(message: Localize("error_unexpected"), debugMessage: debugMessage)
    }
    
    
    class func BasicResponseErrors(response: Response) -> NSError {
        var message: String?
        var debugMessage: String?
        
        switch (response.status, response.statusCode) {
			
		case (.ApiError, 10009), (.SessionExpired, _):
			OCM.shared.delegate?.sessionExpired()
			
        case (.ApiError, _):
            debugMessage = response.error?.userInfo[kGIGNetworkErrorMessage] as? String
            
        case (.NoInternet, _):
            message = Localize("error_no_internet")
            
        case (.Timeout, _):
            message = Localize("error_timeout")
            
        default:
            message = Localize("error_unexpected")
            debugMessage = response.error?.userInfo[kGIGNetworkErrorMessage] as? String
        }
        
        let error = NSError.CustomError(message: message, debugMessage: debugMessage, baseError: response.error)
        
        return error
    }
    
    
    func errorMessage() -> String {
        let message = self.userInfo[ErrorMessageKey] as? String ?? Localize("error_unexpected")
        return message
    }
    
}
