//
//  PassbookWrapper.swift
//  OCM
//
//  Created by Carlos Vicente on 10/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGPassbook

enum PassbookWrapperResult: Equatable {
    case success
    case error(NSError)
    case unsupportedVersionError(NSError)
    
    public static func == (lhs: PassbookWrapperResult, rhs: PassbookWrapperResult) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.error(let lMessage), .error(let rMessage)) where lMessage == rMessage: return true
        case (.unsupportedVersionError(let lMessage), .unsupportedVersionError(let rMessage)) where lMessage == rMessage: return true
            
        default: return false
        }
    }
}

protocol PassbookWrapperProtocol {
    func addPassbook(from url: String, completionHandler: @escaping (_ result: PassbookWrapperResult) -> Void)
}

struct PassBookWrapper: PassbookWrapperProtocol {
    fileprivate let passbook = Passbook()
    
    func addPassbook(from url: String, completionHandler: @escaping (_ result: PassbookWrapperResult) -> Void) {
        self.passbook.addPassbookFromUrl(url) { result in
            switch result {
            case .success:
                completionHandler(.success)
                
            case .unsupportedVersionError(let error):
                completionHandler(.unsupportedVersionError(error))

            case .error(let error):
                completionHandler(.error(error))
            }
        }
    }
}
