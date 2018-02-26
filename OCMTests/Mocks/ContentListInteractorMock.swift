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
    
    var associatedContentPathString: String?
    var spyContentList = false
    var spyTraceSectionLoad = false
    var spyContentVersionUpdated = false
    
    // MARK: - ContentListInteractorProtocol
    
    var output: ContentListInteractorOutput?
    
    func contentList(forcingDownload force: Bool) {
        self.spyContentList = true
    }

    func contentList(matchingString string: String) {
        self.spyContentList = true
    }
    
    func contentVersionUpdated() {
        self.spyContentVersionUpdated = true
    }
    
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        
    }
    
    func traceSectionLoadForContentList() {
        self.spyTraceSectionLoad = true
    }
    
    func associatedContentPath() -> String? {
        return self.associatedContentPathString
    }
    
    func associatedSectionPath() -> String? {
        return nil
    }
    
    func contentVersion() -> String? {
        return nil
    }
    
}
