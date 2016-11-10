//
//  ContentListPresenter.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

enum ViewState {
    case error
    case loading
    case showingContent
    case noContent
}

enum Authentication {
    case logged
    case anonymous
}


protocol ContentListView {
    func layout(_ layout: LayoutDelegate)
	func show(_ contents: [Content])
    func state(_ state: ViewState)
    func show(error: String)
}

class ContentListPresenter {
	
	let path: String
	let view: ContentListView
    var contents = [Content]()
	let contentListInteractor: ContentListInteractor
    var currentFilterTag: String?
    
    // MARK: - Init
    
    init(path: String, view: ContentListView, contentListInteractor: ContentListInteractor) {
        self.path = path
        self.view = view
        self.contentListInteractor = contentListInteractor
    }
    
    // MARK: - PUBLIC
    
	func viewDidLoad() {
        self.fetchContent(showLoadingState: true)
	}
	
    func applicationDidBecomeActive() {
        self.fetchContent(showLoadingState: false)
    }
    
    func show(contents: [Content]) {
        if contents.isEmpty {
            self.view.state(.noContent)
        } else {
            self.view.show(contents)
            self.view.state(.showingContent)
        }
    }
    
    func userDidSelectContent(_ content: Content, viewController: UIViewController) {
        //User choose content
        if Config.loginState == Authentication.anonymous &&
            content.requiredAuth == "logged" {
            OCM.shared.delegate?.requiredUserAuthentication()
        } else {
            _ = content.openAction(from: viewController)
        }
	}
	
    func userDidFilter(byTag tag: String?) {
        
        self.currentFilterTag = tag
        
        if let tag = tag {
            let filteredContent = self.contents.filter(byTag: tag)
           self.show(contents: filteredContent)
        } else {
            self.show(contents: self.contents)
        }
    }
    
    func userDidRetryConnection() {
        self.fetchContent(showLoadingState: true)
    }
    
    // MARK: - PRIVATE
    
    func fetchContent(showLoadingState: Bool) {

        if showLoadingState { self.view.state(.loading) }

        self.contentListInteractor.contentList(from: self.path) { result in
            switch result {
            case .success(let contentList):
                self.view.layout(contentList.layout)
                self.contents = contentList.contents
                
                var contentsToShow = self.contents
                
                if let tag = self.currentFilterTag {
                    contentsToShow = self.contents.filter(byTag: tag)
                }
                
                self.show(contents: contentsToShow)
            case .empty:
                LogInfo("Empty")
                self.view.state(.noContent)
                
            case .error:
                self.view.show(error: "There was a problem getting the content")
                self.view.state(.error)
            }
        }
    }
}
