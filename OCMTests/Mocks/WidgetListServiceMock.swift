//
//  WidgetListServiceMock.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
@testable import ZeusSDK


class WidgetListServiceMock: PWidgetListService {
    
    // INPUTS
    var inResult: WigetListServiceResult!
    
    
    // OUTPUTS
    var outFetchWidgetList: (called: Bool, maxWidth: Int, minWidth: Int)!
    
    func fetchWidgetList(maxWidth maxWidth: Int, minWidth: Int, completionHandler: WigetListServiceResult -> Void) {
        self.outFetchWidgetList = (true, maxWidth, minWidth)
        completionHandler(self.inResult)
    }
    
}
