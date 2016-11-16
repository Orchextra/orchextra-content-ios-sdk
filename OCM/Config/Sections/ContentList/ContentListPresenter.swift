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

enum RequestType {
    case content(String)
    case search(String)
}

protocol ContentListView {
    func layout(_ layout: LayoutDelegate)
	func show(_ contents: [Content])
    func state(_ state: ViewState)
    func show(error: String)
}

class ContentListPresenter {
	
	let path: String?
	let view: ContentListView
    var contents = [Content]()
	let contentListInteractor: ContentListInteractor
    var currentFilterTag: String?
    var lastRequest: RequestType?
    
    // MARK: - Init
    
    init(view: ContentListView, contentListInteractor: ContentListInteractor, path: String? = nil) {
        self.path = path
        self.view = view
        self.contentListInteractor = contentListInteractor
    }
    
    // MARK: - PUBLIC
    
	func viewDidLoad() {
        if let path = self.path {
            self.fetchContent(fromPath: path, showLoadingState: true)
        }
	}
	
    func applicationDidBecomeActive() {
        if let path = self.path {
            self.fetchContent(fromPath: path, showLoadingState: false)
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
        if let request = self.lastRequest {
            switch request {
            case .content(let path):
                self.fetchContent(fromPath: path, showLoadingState: true)
            case .search(let searchString):
                self.fetchContent(matchingString: searchString, showLoadingState: true)
            }
        }
    }
    
    // MARK: - PRIVATE
    
    private func fetchContent(fromPath path: String, showLoadingState: Bool) {
        self.lastRequest = .content(path)
        if showLoadingState { self.view.state(.loading) }

        self.contentListInteractor.contentList(from: path) { result in

            switch result {
                case .success(let contentList):
                    self.contents = contentList.contents
                default: break
            }
            
            self.show(contentListResponse: result)
        }
    }
    
    private func fetchContent(matchingString searchString: String, showLoadingState: Bool) {
        self.lastRequest = .search(searchString)
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
