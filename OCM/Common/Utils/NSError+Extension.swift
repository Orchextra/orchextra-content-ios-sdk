//
//  NSError+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


extension NSError {

    class func CustomError(message: String? = nil, debugMessage: String? = nil, baseError: NSError? = nil) -> NSError {
        var userInfo: [AnyHashable: Any] = baseError?.userInfo ?? [:]
        let code = baseError?.code ?? -1

        if message != nil {
            userInfo[ErrorConstants.ErrorMessageKey] = message!
        }

        if debugMessage != nil {
            userInfo[ErrorConstants.ErrorDebugMessageKey] = debugMessage!
        }

        return NSError(domain: Bundle.OCMBundle().bundleIdentifier ?? "no_bundle", code: code, userInfo: userInfo)
    }

    class func UnexpectedError(_ debugMessage: String? = nil) -> NSError {
        return NSError.CustomError(message: Localize("error_unexpected"), debugMessage: debugMessage)
    }


    class func BasicResponseErrors(_ response: Response) -> NSError {
        var message: String?
        var debugMessage: String?

        switch (response.status, response.statusCode) {

		case (.apiError, 10009), (.sessionExpired, _):
			OCM.shared.delegate?.sessionExpired()

        case (.apiError, _):
            debugMessage = response.error?.userInfo[kGIGNetworkErrorMessage] as? String

        case (.noInternet, _):
            message = Localize("error_no_internet")

        case (.timeout, _):
            message = Localize("error_timeout")

        default:
            message = Localize("error_unexpected")
            debugMessage = response.error?.userInfo[kGIGNetworkErrorMessage] as? String
        }

        let error = NSError.CustomError(message: message, debugMessage: debugMessage, baseError: response.error)

        return error
    }


    func errorMessage() -> String {
        let message = self.userInfo[ErrorConstants.ErrorMessageKey] as? String ?? Localize("error_unexpected")
        return message
    }

}
