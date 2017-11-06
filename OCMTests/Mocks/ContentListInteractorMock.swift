//
//  ContentListInteractorMock.swift
//  OCM
//
//  Created by José Estela on 14/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class ContentListInteractorMock: ContentListInteractorProtocol {
    
    // MARK: - Attributes
    
    var spyContentList = false
    var spySectionForContentWithPath = false
    
    // MARK: - ContentListInteractorProtocol
    
    func contentList(from path: String, forcingDownload force: Bool, completionHandler: @escaping (ContentListResult) -> Void) {
        self.spyContentList = true
    }
    
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.spyContentList = true
    }
    
    func sectionForContentWith(path: String) -> Section? {
        self.spySectionForContentWithPath = true
        return nil
    }
}
