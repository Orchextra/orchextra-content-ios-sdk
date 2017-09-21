//
//  MenuInteractor.swift
//  OCM
//
//  Created by Judith Medina on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

public enum MenuListResult {
    case success(menus: [Menu])
    case empty
    case error(message: String)
}

class MenuInteractor {
    
    // MARK: Private properties
    
    private let sessionInteractor: SessionInteractorProtocol
    private let contentDataManager: ContentDataManager
    
    // MARK: Initializer
    
    init(sessionInteractor: SessionInteractorProtocol, contentDataManager: ContentDataManager) {
        self.sessionInteractor = sessionInteractor
        self.contentDataManager = contentDataManager
    }
    
    // MARK: Public methods
    
    func loadMenus(forceDownload: Bool, completionHandler: @escaping (MenuListResult, Bool) -> Void) {
        self.contentDataManager.loadMenus(forcingDownload: forceDownload) { result, fromCache in
            switch result {
            case .success(let menus):
                completionHandler(MenuListResult.success(menus: menus), fromCache)
            case .error(let error):
                completionHandler(MenuListResult.error(message: error.error.localizedDescription), fromCache)
            }
        }
    }
    
}
