//
//  ContentListServices.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ContentListServiceProtocol {
	func getContentList(with path: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void)
    func getContentList(matchingString: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void)
    func cancelActiveRequest()
}

class ContentListService: ContentListServiceProtocol {
    
    var activeRequest: Request?
    
    // MARK: - Public methods
    
    func getContentList(with path: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: path
        )
        request.fetch(renewingSessionIfExpired: true) { response in
            switch response.status {
            case .success:
                do {
                    let json = try response.json()
                    completionHandler(.success(json))
                } catch {
                    logInfo("Error in request")
                    logInfo(String(describing: response))
                    if let body = response.body, let stringBody = String(data: body, encoding: String.Encoding.utf8) {
                        logInfo(stringBody)
                    }
                    let error = response.error ?? NSError.unexpectedError("Error parsing json")
                    logError(error)
                    return completionHandler(.error(error))
                }
            default:
                let error = response.error ?? NSError.OCMBasicResponseErrors(response).error
                logError(error)
                completionHandler(.error(error))
            }
            self.activeRequest = nil
        }
        self.activeRequest = request
    }
    
    func getContentList(matchingString searchString: String, completionHandler: @escaping (Result<JSON, NSError>) -> Void) {
        let queryValue = "\(searchString)"
        let request = Request.OCMRequest(
			method: "GET",
			endpoint: "/search",
			urlParams: [
				"search": queryValue
			],
			bodyParams: nil
        )
        
        request.fetch(renewingSessionIfExpired: true) { response in
            switch response.status {
            case .success:
                do {
                    let json = try response.json()
                    completionHandler(.success(json))
                } catch {
                    let error = response.error ?? NSError.unexpectedError("Error parsing json")
                    logError(error)
                    return completionHandler(.error(error))
                }
            default:
                let error = response.error ?? NSError.OCMBasicResponseErrors(response).error
                logError(error)
                completionHandler(.error(error))
            }
        }
    }
    
    func cancelActiveRequest() {
        self.activeRequest?.cancel()
    }

}
