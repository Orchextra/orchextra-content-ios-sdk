//
//  WidgetListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

enum WidgetListResult {
    case success(widgets: [Widget])
    case empty
    case error(message: String)
}


struct WidgetListInteractor {
    
    let service: PWidgetListService
    let storage: Storage
    
    func widgetList(maxWidth: Int, minWidth: Int, completionHandler: @escaping (WidgetListResult) -> Void) {
        self.service.fetchWidgetList(maxWidth: maxWidth, minWidth: minWidth) { result in
            switch result {
                
            case .success(let widgets):
                self.storage.widgetList = widgets
                
                if widgets.count > 0 {
                    completionHandler(.success(widgets: widgets))
                }
                else {
                    completionHandler(.empty)
                }
                
            case .error(let error):
                completionHandler(.error(message: error.errorMessage()))
            }
        }
    }
    
}
