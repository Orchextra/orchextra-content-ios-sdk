//
//  ContentListMock.swift
//  OCM
//
//  Created by José Estela on 8/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class ContentListViewMock: ContentListView {
    
    // MARK: - Attributes
    
    var spyShowContents = (called: false, contents: [])
    var spyShowError = (called: false, error: "")
    var spyState: (called: Bool, state: ViewState?) = (called: false, state: nil)
    
    // MARK: - ContentListView
    
    func layout(_ layout: LayoutDelegate) {
    
    }
    
    func show(_ contents: [Content]) {
        self.spyShowContents.called = true
        self.spyShowContents.contents = contents
    }
    
    func state(_ state: ViewState) {
        self.spyState.called = true
        self.spyState.state = state
    }
    
    func show(error: String) {
        self.spyShowError.called = true
        self.spyShowError.error = error
    }
    
    func set(retryBlock: @escaping () -> Void) {
    
    }
}
