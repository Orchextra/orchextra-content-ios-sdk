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
    
    var sectionReturn: Section?
    
    func sectionForContentWith(path: String) -> Section? {
        return nil
    }
    
    func sectionForActionWith(identifier: String) -> Section? {
        return self.sectionReturn
    }
    
}
