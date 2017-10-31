//
//  ActionInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

struct ActionInteractor {
	
	let contentDataManager: ContentDataManager
	
    /// Method to get an action asynchronously
    ///
    /// - Parameters:
    ///   - url: The url of the action
    ///   - completion: Block to return the action
    func action(forcingDownload force: Bool = false, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        self.contentDataManager.loadElement(forcingDownload: force, with: identifier) { result in
            switch result {
            case .success(let action):
                completion(action, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }
}
