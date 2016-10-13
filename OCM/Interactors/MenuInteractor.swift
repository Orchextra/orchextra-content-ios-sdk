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
    
    let menuService =  MenuService()
    
    func loadMenus(completionHandler: @escaping (MenuListResult) -> Void) {
        
        menuService.getMenus { result in
            
            switch result {
                
            case .success(let menus):
                
                completionHandler(MenuListResult.success(menus: menus))
                
            case .error(let error):
                completionHandler(MenuListResult.error(message: error.localizedDescription))

            }
        }
    }
}
