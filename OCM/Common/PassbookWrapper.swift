//
//  PassbookWrapper.swift
//  OCM
//
//  Created by Carlos Vicente on 10/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGPassbook

enum PassbookWrapperResult {
    case success
    case error(NSError)
    case unsupportedVersionError(NSError)
}

protocol PassbookWrapperProtocol {
     func addPassbook(from url: String, completionHandler: @escaping (PassbookWrapperResult) -> Void)
}

struct PassBookWrapper: PassbookWrapperProtocol {
    fileprivate let passbook = Passbook()
    
    func addPassbook(from url: String, completionHandler: @escaping (PassbookWrapperResult) -> Void) {
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
