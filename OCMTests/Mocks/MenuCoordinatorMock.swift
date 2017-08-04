//
//  MenuCoordinatorMock.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 03/08/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

import Foundation
@testable import OCMSDK

class MenuCoordinatorMock: MenuCoordinatorProtocol {
    
    // MARK: - Attributes
    
    var spyMenus = false
    
    // MARK: - MenuCoordinatorProtocol
    
    func loadMenus() {
        
        self.spyMenus = true
    }
}
