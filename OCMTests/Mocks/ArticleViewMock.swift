//
//  ArticleViewMock.swift
//  OCMTests
//
//  Created by José Estela on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class ArticleViewMock: ArticleUI {
    
    var spyShowViewForAction: (called: Bool, action: Action?) = (called: false, action: nil)
    
    func show(article: Article) {}
    func update(with article: Article) {}
    
    func showViewForAction(_ action: Action) {
        self.spyShowViewForAction.called = true
        self.spyShowViewForAction.action = action
    }
    
    func showLoadingIndicator() {}
    func dismissLoadingIndicator() {}
    func displaySpinner(show: Bool) {}
    
}
