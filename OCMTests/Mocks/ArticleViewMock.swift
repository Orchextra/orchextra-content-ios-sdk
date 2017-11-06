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
    
    func show(article: Article) {}
    func update(with article: Article) {}
    func showViewForAction(_ action: Action) {}
    func showLoadingIndicator() {}
    func dismissLoadingIndicator() {}
    func displaySpinner(show: Bool) {}
    
}
