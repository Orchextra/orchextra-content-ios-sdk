//
//  OCMError.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 03/04/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

public enum OCMError: Error {
    
    case openContentWithNoInternet
    case requestFailure
    case unknown
    
    public func description() -> String {
        switch self {
        case .openContentWithNoInternet:
            return Config.strings.internetConnectionRequired
        case .requestFailure:
            return "Request failed"
        case .unknown:
            return "Something went wrong"
        }
    }
}
