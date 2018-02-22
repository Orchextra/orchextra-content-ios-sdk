//
//  ContentListMock.swift
//  OCM
//
//  Created by José Estela on 8/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class ContentListViewMock: ContentListUI {
    
    // MARK: - Attributes
    
    var spyShowContents = (called: false, contents: [])
    var spyShowError = (called: false, error: "")
    var spyShowAlert = (called: false, message: "")
    var spyState: (called: Bool, state: ViewState?) = (called: false, state: nil)
    
    // MARK: - ContentListUI
    
    func layout(_ layout: Layout) {
    
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
    
    func showAlert(_ message: String) {
        self.spyShowAlert.called = true
        self.spyShowAlert.message = message
    }
    
    func set(retryBlock: @escaping () -> Void) {
    
    }
    
    func showUpdatedContentMessage(with contents: [Content]) {
    
    }
    
    func reloadVisibleContent() {
    
    }
    
    func stopRefreshControl() {
        
    }
    
    
    func displaySpinner(show: Bool) {
        
    }
    
    func showNewContentAvailableView(with contents: [Content]) {
        
    }
    
    func dismissNewContentAvailableView() {
        
    }
}
