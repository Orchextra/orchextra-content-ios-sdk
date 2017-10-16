//
//  ContentVersionInteractor.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 13/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol ContentVersionInteractorProtocol {
    func loadContentVersion(completionHandler: @escaping (Any) -> Void)
}

class ContentVersionInteractor: ContentVersionInteractorProtocol {

    // MARK: Private properties
    
    private let contentDataManager: ContentDataManager
    
    // MARK: Initializer
    
    init(contentDataManager: ContentDataManager) {
        self.contentDataManager = contentDataManager
    }
    
    // MARK: Public methods
    
    func loadContentVersion(completionHandler: @escaping (Any) -> Void) {
        self.contentDataManager.loadContentVersion { result in
            print("!!! :)")
            completionHandler(result)
        }
    }
}
