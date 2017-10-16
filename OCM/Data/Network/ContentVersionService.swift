//
//  ContentVersionService.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 11/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ContentVersionServiceProtocol {

    func getContentVersion(completion: @escaping (Result<String, OCMRequestError>) -> Void)
}

struct ContentVersionService: ContentVersionServiceProtocol {
    
    func getContentVersion(completion: @escaping (Result<String, OCMRequestError>) -> Void) {
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: "/version"
        )
        request.fetch(renewingSessionIfExpired: true) { response in
            switch response.status {
            case .success:
                guard let json = try? response.json(), let version = json.toString(), !version.isEmpty() else {
                    let error = NSError.OCMError(message: nil, debugMessage: "Unexpected JSON format")
                    completion(Result.error(OCMRequestError(error: error, status: ResponseStatus.unknownError)))
                    return
                }
                completion(Result.success(version))
            default:
                let error = NSError.OCMBasicResponseErrors(response)
                completion(Result.error(error))
            }
        }
    }
}
