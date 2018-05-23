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
    var spyShowLoadingIndicatorCalled = false
    var spyDismissLoadingIndicatorCalled = false
    var spyShowErrorView = (called: false, show: false)
    var spyShowNoContentView = (called: false, show: false)
    
    // MARK: - ContentListUI
    
    func showLoadingView(_ show: Bool) {
        self.spyShowLoadingView.called = true
        self.spyShowLoadingView.show = show
    }
    
    func showLoadingIndicator() {
        self.spyShowLoadingIndicatorCalled = true
    }
    
    func dismissLoadingIndicator() {
        self.spyDismissLoadingIndicatorCalled = true
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
    
    func showLoadingView() {
        
    }
    
    func dismissLoadingView() {
        
    }
    
    func showNewContentAvailableView() {
        
    }
    
    func dismissNewContentAvailableView() {
        
    }
    
    func dismissPaginationView(_ completion: (() -> Void)?) {
        
    }
    
    func appendContents(_ contents: [Content], completion: (() -> Void)?) {
        
    }
    
    func enablePagination() {
        
    }
    
    func disablePagination() {
        
    }
    
    func disableRefresh() {
        
    }
    
    func enableRefresh() {
        
    }
}
