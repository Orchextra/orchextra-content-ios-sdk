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
    var spyShowAlert = (called: false, message: "")
    var spyShowLoadingView = (called: false, show: false)
    var spyShowLoadingViewForAction = (called: false, show: false)
    var spyShowErrorView = (called: false, show: false)
    var spyShowNoContentView = (called: false, show: false)
    
    // MARK: - ContentListUI
    
    func showLoadingView(_ show: Bool) {
        self.spyShowLoadingView.called = true
        self.spyShowLoadingView.show = show
    }
    
    func showLoadingViewForAction(_ show: Bool) {
        self.spyShowLoadingViewForAction.called = true
        self.spyShowLoadingViewForAction.show = show
    }
    
    func showErrorView(_ show: Bool) {
        self.spyShowErrorView.called = true
        self.spyShowErrorView.show = show
    }
    
    func showNoContentView(_ show: Bool) {
        self.spyShowNoContentView.called = true
        self.spyShowNoContentView.show = show
    }
    
    func cleanContents() {
        
    }
    
    func showContents(_ contents: [Content], layout: Layout) {
        self.spyShowContents.called = true
        self.spyShowContents.contents = contents
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
    
    func showNewContentAvailableView() {
        
    }
    
    func dismissNewContentAvailableView() {
        
    }
    
    func dismissPaginationControlView() {
        
    }
    
    func appendContents(_ contents: [Content], completion: @escaping () -> Void) {
        
    }
    
    func enablePagination() {
        
    }
    
    func disablePagination() {
        
    }
}
