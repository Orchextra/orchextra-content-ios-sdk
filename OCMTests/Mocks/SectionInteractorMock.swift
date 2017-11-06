//
//  SectionInteractorMock.swift
//  OCMTests
//
//  Created by Jerilyn Goncalves on 02/11/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

class SectionInteractorMock: SectionInteractorProtocol {
    
    func sectionForContentWith(path: String) -> Section? {
        return nil
    }
    
    func sectionForArticleWith(identifier: String) -> Section? {
        return nil
    }
    
    func sectionForWebviewWith(identifier: String) -> Section? {
        return nil
    }
}
