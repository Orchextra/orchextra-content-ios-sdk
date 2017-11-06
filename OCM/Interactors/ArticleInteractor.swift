//
//  ArticleInteractor.swift
//  OCM
//
//  Created by Eduardo Parada on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct ArticleInteractor {
    
    var elementUrl: String?
    let sectionInteractor: SectionInteractorProtocol
    var ocm: OCM
    
    func traceSectionLoadForArticle() {
        guard
            let elementUrl = self.elementUrl,
            let section = self.sectionInteractor.sectionForActionWith(identifier: elementUrl)
            else {
                LogWarn("Element url or section is nil")
                return
        }
        self.ocm.eventDelegate?.sectionDidLoad(section)
    }
}
