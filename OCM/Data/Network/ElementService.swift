//
//  ElementService.swift
//  OCM
//
//  Created by José Estela on 17/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ElementService {
    
    // MARK: - Public methods
    
    func getElement(with id: String, completion: @escaping (Result<Action, NSError>) -> Void) {
        guard let parsedId = id.components(separatedBy: "/").last else {
            completion(.error(NSError.UnexpectedError("Error getting id")))
            return
        }
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: "/element/\(parsedId)"
        )
        request.fetch { response in
            switch response.status {
            case .success:
                do {
                    let json = try response.json()
                    guard let action = ActionFactory.action(from: json["element"]!) else {
                        completion(.error(NSError.UnexpectedError("Error parsing json")))
                        return
                    }
                    completion(.success(action))
                } catch {
                    let error = NSError.UnexpectedError("Error parsing json")
                    LogError(error)
                    completion(.error(error))
                }
            default:
                let error = NSError.OCMBasicResponseErrors(response)
                LogError(error)
                completion(.error(error))
            }
        }
    }
}
