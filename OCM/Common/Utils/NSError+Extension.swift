//
//  NSError+Extension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct OCMRequestError {
    let error: NSError
    let status: ResponseStatus
}

extension NSError {

    class func OCMError(message: String? = nil, debugMessage: String? = nil, baseError: NSError? = nil) -> NSError {
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

    class func unexpectedError(_ debugMessage: String? = nil) -> NSError {
        return NSError.OCMError(message: localize("error_unexpected"), debugMessage: debugMessage)
    }


    class func OCMBasicResponseErrors(_ response: Response) -> OCMRequestError {
        var message: String?
        var debugMessage: String?

        switch (response.status, response.statusCode) {
        case (.apiError, _):
            debugMessage = response.error?.userInfo[kGIGNetworkErrorMessage] as? String

        case (.noInternet, _):
            message = localize("error_no_internet")

        case (.timeout, _):
            message = localize("error_timeout")

        default:
            message = localize("error_unexpected")
            debugMessage = response.error?.userInfo[kGIGNetworkErrorMessage] as? String
        }

        let error = NSError.OCMError(message: message, debugMessage: debugMessage, baseError: response.error)

        return OCMRequestError(error: error, status: response.status)
    }


    func errorMessageOCM() -> String {
        let message = self.userInfo[ErrorConstants.ErrorMessageKey] as? String ?? localize("error_unexpected")
        return message
    }

}
