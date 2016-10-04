//
//  WidgetListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

enum WidgetListResult {
    case Success(widgets: [Widget])
    case Empty
    case Error(message: String)
}


struct WidgetListInteractor {
    
    let service: PWidgetListService
    let storage: Storage
    
    func widgetList(maxWidth maxWidth: Int, minWidth: Int, completionHandler: WidgetListResult -> Void) {
        self.service.fetchWidgetList(maxWidth: maxWidth, minWidth: minWidth) { result in
            switch result {
                
            case .Success(let widgets):
                self.storage.widgetList = widgets
                
                if widgets.count > 0 {
                    completionHandler(.Success(widgets: widgets))
                }
                else {
                    completionHandler(.Empty)
                }
                
            case .Error(let error):
                completionHandler(.Error(message: error.errorMessage()))
            }
        }
    }
    
}
