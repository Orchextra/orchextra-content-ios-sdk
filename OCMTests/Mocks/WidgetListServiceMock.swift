//
//  ContentListServiceMock.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK


class ContentListServiceMock: PContentListService {
    
    // INPUTS
    var inResult: WigetListServiceResult!
    
    
    // OUTPUTS
    var outFetchContentList: (called: Bool, maxWidth: Int, minWidth: Int)!
    
    func fetchContentList(maxWidth: Int, minWidth: Int, completionHandler: @escaping (WigetListServiceResult) -> Void) {
        self.outFetchContentList = (true, maxWidth, minWidth)
        completionHandler(self.inResult)
    }
    
}
