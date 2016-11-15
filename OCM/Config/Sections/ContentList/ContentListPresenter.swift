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
    
    func userDidSelectContent(_ content: Content, viewController: UIViewController) {
        //User choose content
        if Config.loginState == Authentication.anonymous &&
            content.requiredAuth == "logged" {
            OCM.shared.delegate?.requiredUserAuthentication()
        } else {
            _ = content.openAction(from: viewController)
        }
	}
	
    func userDidFilter(byTag tag: String) {
        
        self.currentFilterTag = tag
        
        let filteredContent = self.contents.filter(byTag: tag)
        self.show(contents: filteredContent)
    }
    
    func userDidSearch(byString string: String) {
        self.fetchContent(matchingString: string, showLoadingState: true)
    }
    
    func userAskForAllContent() {
        self.currentFilterTag = nil
        self.show(contents: self.contents)
    }
    
    func userDidRetryConnection() {
        self.fetchContent(showLoadingState: true)
    }
    
    // MARK: - PRIVATE
    
    private func fetchContent(showLoadingState: Bool) {

        if showLoadingState { self.view.state(.loading) }

        self.contentListInteractor.contentList(from: self.path) { result in

            switch result {
                case .success(let contentList):
                    self.contents = contentList.contents
                default: break
            }
            
            self.show(contentListResponse: result)
        }
    }
    
    private func fetchContent(matchingString searchString: String, showLoadingState: Bool) {
        
        if showLoadingState { self.view.state(.loading) }
        
        self.contentListInteractor.contentList(matchingString: searchString) {  result in
            self.show(contentListResponse: result)
        }
    }
    
    private func show(contentListResponse: ContentListResult) {
        switch contentListResponse {
        case .success(let contentList):
            self.show(contentList: contentList)
        case .empty:
            LogInfo("Empty")
            self.view.state(.noContent)
            
        case .error:
            self.view.show(error: "There was a problem getting the content")
            self.view.state(.error)
        }
    }

    private func show(contentList: ContentList) {
        self.view.layout(contentList.layout)
        
        var contentsToShow = contentList.contents
        
        if let tag = self.currentFilterTag {
            contentsToShow = contentsToShow.filter(byTag: tag)
        }
        
        self.show(contents: contentsToShow)
    }
    
    private func show(contents: [Content]) {
        if contents.isEmpty {
            self.view.state(.noContent)
        } else {
            self.view.show(contents)
            self.view.state(.showingContent)
        }
    }
}
