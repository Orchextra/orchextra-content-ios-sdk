//
//  ElementService.swift
//  OCM
//
//  Created by José Estela on 17/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ElementServiceInput {
    func getElement(with identifier: String, completion: @escaping (Result<Action, NSError>) -> Void)
}

struct ElementService: ElementServiceInput {
    
    // MARK: - Public methods
    
    func getElement(with identifier: String, completion: @escaping (Result<Action, NSError>) -> Void) {
        guard let parsedId = identifier.components(separatedBy: "/").last else {
            completion(.error(NSError.unexpectedError("Error getting identifier")))
            return
        }
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: "/element/\(parsedId)"
            // TODO: ADD!!!! urlParams: ["withThumbnails": Config.thumbnailEnabled ? 1 : 0]
        )
        request.fetch(renewingSessionIfExpired: true) { response in
            switch response.status {
            case .success:
                do {
                    let json = try response.json()
                    guard let element = json["element"] else {
                        completion(.error(NSError.unexpectedError("Error parsing json")))
                        return }
                    guard let action = ActionFactory.action(from: element, identifier: "") else {
                        completion(.error(NSError.unexpectedError("Error parsing json")))
                        return
                    }
                    completion(.success(action))
                } catch {
                    let error = NSError.unexpectedError("Error parsing json")
                    logError(error)
                    completion(.error(error))
                }
            default:
                let error = NSError.OCMBasicResponseErrors(response)
                logError(error.error)
                completion(.error(error.error))
            }
        }
    }
}
