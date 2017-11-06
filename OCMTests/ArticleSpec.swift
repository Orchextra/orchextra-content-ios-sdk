//
//  ArticleSpec.swift
//  OCMTests
//
//  Created by José Estela on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import OCMSDK

class ArticleSpec: QuickSpec {
    
    // MARK: - Attributes
    
    var presenter: ArticlePresenter!
    var viewMock: ArticleViewMock!
    var article: Article!
    var actionInteractorMock: ActionInteractorMock!
    var reachability: ReachabilityMock!
    var ocm: OCM!
    var actionScheduleManager: ActionScheduleManager!
    
    override func spec() {
        
        beforeEach {
            self.viewMock = ArticleViewMock()
            self.article = Article(slug: "", name: "", preview: nil, elements: [])
            self.actionInteractorMock = ActionInteractorMock()
            self.ocm = OCM()
            self.actionScheduleManager = ActionScheduleManager()
            self.presenter = ArticlePresenter(
                article: self.article,
                view: self.viewMock,
                actionInteractor: self.actionInteractorMock,
                ocm: self.ocm,
                actionScheduleManager: self.actionScheduleManager
            )
        }
        
        afterEach {
            self.viewMock = nil
            self.article = nil
            self.actionInteractorMock = nil
            self.presenter = nil
            self.reachability = nil
            self.ocm = nil
            self.actionScheduleManager = nil
        }
        
        describe("test article") {
            
        }
    }
}
