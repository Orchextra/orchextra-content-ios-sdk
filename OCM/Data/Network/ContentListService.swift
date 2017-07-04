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
	func getContentList(with path: String, completionHandler: @escaping (Result<JSON, Error>) -> Void)
    func getContentList(matchingString: String, completionHandler: @escaping (Result<JSON, Error>) -> Void)
}

class ContentListService: ContentListServiceProtocol {
    
    // MARK: - Attributes

    private var currentRequests: [Request] = []
    
    // MARK: - Public methods
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getContentList(with path: String, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: path
        )
        
        self.currentRequests.append(request)
        
        request.fetch { response in
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
                    if !self.checkIfErrorIsCancelled(for: response) {
                        let error = NSError.unexpectedError("Error parsing json")
                        logError(error)
                        return completionHandler(.error(error))
                    }
                }
            default:
                if !self.checkIfErrorIsCancelled(for: response) {
                    let error = NSError.OCMBasicResponseErrors(response)
                    logError(error.error)
                    completionHandler(.error(error.error))
                }
            }
            self.removeRequest(request)
        }
    }
    
    func getContentList(matchingString searchString: String, completionHandler: @escaping (Result<JSON, Error>) -> Void) {
        let queryValue = "\(searchString)"
        let request = Request.OCMRequest(
			method: "GET",
			endpoint: "/search",
			urlParams: [
				"search": queryValue
			],
			bodyParams: nil
        )
        self.currentRequests.append(request)
        request.fetch { response in
            switch response.status {
            case .success:
                do {
                    let json = try response.json()
                    completionHandler(.success(json))
                } catch {
                    if !self.checkIfErrorIsCancelled(for: response) {
                        let error = NSError.unexpectedError("Error parsing json")
                        logError(error)
                        return completionHandler(.error(error))
                    }
                }
            default:
                if !self.checkIfErrorIsCancelled(for: response) {
                    let error = NSError.OCMBasicResponseErrors(response)
                    logError(error.error)
                    completionHandler(.error(error.error))
                }
            }
            self.removeRequest(request)
        }
    }
    
    // MARK: - Private methods
    
    private func removeRequest(_ request: Request) {
        guard let index = self.currentRequests.index(where: { $0.baseURL == request.baseURL }) else { return }
        self.currentRequests.remove(at: index)
    }
    
    private func checkIfErrorIsCancelled(for response: Response) -> Bool {
        if let errorCode = response.error?.code {
            return errorCode == NSURLErrorCancelled
        }
        return false
    }
    
    @objc private func willResignActive() {
        for request in self.currentRequests {
            request.cancel()
            self.removeRequest(request)
        }
    }
}
