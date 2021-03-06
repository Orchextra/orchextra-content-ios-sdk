//
//  ArticleInteractorMock.swift
//  OCMTests
//
//  Created by Jerilyn Goncalves on 12/01/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit
@testable import OCMSDK

class ArticleInteractorMock: ArticleInteractorProtocol {
    
    // MARK: - Attributes

    var spyPerformActionCalled = false

    // MARK: - ArticleInteractorOutput

    var output: ArticleInteractorOutput?

    // MARK: - ArticleInteractorProtocol

    func traceSectionLoadForArticle() {}
    
    func action(of element: Element, with info: Any) {
        self.spyPerformActionCalled = true
    }
    
}
