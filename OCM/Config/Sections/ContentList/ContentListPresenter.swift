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
    case noSearchResults
}

enum Authentication: String {
    case logged
    case anonymous
}

enum ContentSource {
    case initialContent
    case search
}

protocol ContentListView {
    func layout(_ layout: LayoutDelegate)
	func show(_ contents: [Content])
    func state(_ state: ViewState)
    func show(error: String)
    func set(retryBlock: @escaping () -> Void)
}

class ContentListPresenter {
	
	let defaultContentPath: String?
	let view: ContentListView
    var contents = [Content]()
	let contentListInteractor: ContentListInteractor
    var currentFilterTag: String?
    
    // MARK: - Init
    
    init(view: ContentListView, contentListInteractor: ContentListInteractor, defaultContentPath: String? = nil) {
        self.defaultContentPath = defaultContentPath
        self.view = view
        self.contentListInteractor = contentListInteractor
    }
    
    // MARK: - PUBLIC
    
	func viewDidLoad() {
        if let defaultContentPath = self.defaultContentPath {
            self.fetchContent(fromPath: defaultContentPath, showLoadingState: true)
        }
	}
	
    func applicationDidBecomeActive() {
        if let defaultContentPath = self.defaultContentPath {
            self.fetchContent(fromPath: defaultContentPath, showLoadingState: false)
        }
    }
    
    func userDidSelectContent(_ content: Content, viewController: UIViewController) {

        if !Config.isLogged &&
            content.requiredAuth == "logged" {
            OCM.shared.delegate?.requiredUserAuthentication()
        } else {
            _ = content.openAction(from: viewController)
        }
	}
	
    func userDidFilter(byTag tag: String) {
        
        self.currentFilterTag = tag
        
        let filteredContent = self.contents.filter(byTag: tag)
        self.show(contents: filteredContent, contentSource: .initialContent)
    }
    
    func userDidSearch(byString string: String) {
        self.fetchContent(matchingString: string, showLoadingState: true)
    }
    
    func userAskForInitialContent() {
        if self.defaultContentPath != nil {
            self.currentFilterTag = nil
            self.show(contents: self.contents, contentSource: .initialContent)
        } else {
            self.clearContent()
        }
    }
    
    // MARK: - PRIVATE
    
    private func fetchContent(fromPath path: String, showLoadingState: Bool) {
        
        if showLoadingState { self.view.state(.loading) }
        
        self.view.set(retryBlock: { self.fetchContent(fromPath: path, showLoadingState: showLoadingState) })

        self.contentListInteractor.contentList(from: path) { result in

            switch result {
                case .success(let contentList):
                    self.contents = contentList.contents
                default: break
            }
            
            self.show(contentListResponse: result, contentSource: .initialContent)
        }
    }
    
    private func fetchContent(matchingString searchString: String, showLoadingState: Bool) {

        if showLoadingState { self.view.state(.loading) }
        
        self.view.set(retryBlock: { self.fetchContent(matchingString: searchString, showLoadingState: showLoadingState) })
        
        self.contentListInteractor.contentList(matchingString: searchString) {  result in
            self.show(contentListResponse: result, contentSource: .search)
        }
    }
    
    private func show(contentListResponse: ContentListResult, contentSource: ContentSource) {
        switch contentListResponse {
        case .success(let contentList):
            self.show(contentList: contentList, contentSource: contentSource)
        case .empty:
            self.showEmptyContentView(forContentSource: contentSource)
            
        case .error:
            self.view.show(error: kLocaleOcmErrorContent)
            self.view.state(.error)
        }
    }

    private func show(contentList: ContentList, contentSource: ContentSource) {
        self.view.layout(contentList.layout)
        
        var contentsToShow = contentList.contents
        
        if let tag = self.currentFilterTag {
            contentsToShow = contentsToShow.filter(byTag: tag)
        }
        
        self.show(contents: contentsToShow, contentSource: contentSource)
    }
    
    private func show(contents: [Content], contentSource: ContentSource) {
        if contents.isEmpty {
            self.showEmptyContentView(forContentSource: contentSource)
        } else {
            self.view.show(contents)
            self.view.state(.showingContent)
        }
    }
    
    private func showEmptyContentView(forContentSource source: ContentSource) {
        switch source {
        case .initialContent:
            self.view.state(.noContent)
        case .search:
            self.view.state(.noSearchResults)
        }
    }
    private func clearContent() {
        self.view.show([])
    }
}
