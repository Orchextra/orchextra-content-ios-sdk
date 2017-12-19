//
//  ContentCoordinatorMock.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 03/08/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

import Foundation
@testable import OCMSDK

class ContentCoordinatorMock: ContentCoordinatorProtocol {
    
    func addObserver(_ observer: ContentListInteractorProtocol) {
        //!!!
    }
    
    func removeObserver(_ observer: ContentListInteractorProtocol) {
        //!!!
    }
    
    // MARK: - Attributes
    
    var spyMenus = false
    
    // MARK: - ContentCoordinatorProtocol
    
    func loadMenus() {
        self.spyMenus = true
    }
    
    func loadVersion() {
        // !!!
    }
    
    func loadVersionForContentUpdate(contentPath: String) {
        // !!!
    }

}
