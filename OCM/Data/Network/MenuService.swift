//
//  MenuService.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct MenuService {
	
	func getMenus(completion: @escaping (Result<JSON, OCMRequestError>) -> Void) {
        let request = Request.OCMRequest(
            method: "GET",
            endpoint: "/menus"
        )
        request.fetch(renewingSessionIfExpired: true) { response in
            switch response.status {
            case .success:
                guard let json = try? response.json() else {
                        let error = NSError.OCMError(message: nil, debugMessage: "Unexpected JSON format")
                        completion(Result.error(OCMRequestError(error: error, status: ResponseStatus.unknownError)))
                        return
                }
                completion(Result.success(json))
            default:
                let error = NSError.OCMBasicResponseErrors(response)
                completion(Result.error(error))
            }
        }
	}
}
