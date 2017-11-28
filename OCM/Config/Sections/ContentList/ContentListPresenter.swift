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

enum ContentTrigger {
    case initialContent
    case refresh
    case search
    case updateNeeded
}

protocol ContentListView: class {
    func layout(_ layout: Layout)
	func show(_ contents: [Content])
    func showNewContentAvailableView(with contents: [Content])
    func dismissNewContentAvailableView()
    func state(_ state: ViewState)
    func show(error: String)
    func showAlert(_ message: String)
    func set(retryBlock: @escaping () -> Void)
    func reloadVisibleContent()
    func stopRefreshControl()
    func displaySpinner(show: Bool)
}

class ContentListPresenter {
	
    weak var view: ContentListView?
    var contents = [Content]()
    var contentListInteractor: ContentListInteractorProtocol
    var currentFilterTags: [String]?
    let reachability = ReachabilityWrapper.shared
    var viewDataStatus: ViewDataStatus = .notLoaded
    var contentTrigger: ContentTrigger?
    let ocm: OCM
    let actionScheduleManager: ActionScheduleManager
    
    // MARK: - Init
    
    init(view: ContentListView, contentListInteractor: ContentListInteractorProtocol, ocm: OCM, actionScheduleManager: ActionScheduleManager) {
        self.view = view
        self.ocm = ocm
        self.actionScheduleManager = actionScheduleManager
        self.contentListInteractor = contentListInteractor
        self.contentListInteractor.output = self
    }
    
    // MARK: - PUBLIC
    
	func viewDidLoad() {
        self.fetchContent(of: .initialContent)
	}
    
    func userDidSelectContent(_ content: Content, viewController: UIViewController) {
        if self.reachability.isReachable() {
            self.openContent(content, in: viewController)
        } else if Config.offlineSupportConfig != nil, ContentCacheManager.shared.cachedArticle(for: content) != nil {
            self.openContent(content, in: viewController)
        } else {
            self.view?.showAlert(Config.strings.internetConnectionRequired)
        }
	}
	
    func userDidFilter(byTag tags: [String]) {
        self.currentFilterTags = tags
        let filteredContent = self.contents.filter(byTags: tags)
        self.show(contents: filteredContent, contentTrigger: .initialContent)
    }
    
    func userDidSearch(byString string: String) {
        self.fetchContent(matchingString: string, showLoadingState: true)
    }
    
    func userDidRefresh() {
        self.view?.dismissNewContentAvailableView()
        self.fetchContent(of: .refresh)
    }
    
    func userAskForInitialContent() {
        if self.contentListInteractor.associatedContentPath() == nil {
            self.clearContent()
        } else {
            self.currentFilterTags = nil
            self.show(contents: self.contents, contentTrigger: .initialContent)
        }
    }
    
    // MARK: - PRIVATE
    
    fileprivate func fetchContent(of contentTrigger: ContentTrigger) {
        self.view?.set {
            self.fetchContent(of: contentTrigger)
        }
        self.contentTrigger = contentTrigger
        switch contentTrigger {
        case .initialContent:
            self.view?.state(.loading)
        default:
            break
        }
        let forceDownload = (contentTrigger != .initialContent)
        let checkVersion = (Config.offlineSupportConfig != nil && contentTrigger == .refresh)
        self.contentListInteractor.contentList(forcingDownload: forceDownload, checkVersion: checkVersion)
    }
    
    private func fetchContent(matchingString searchString: String, showLoadingState: Bool) {

        if showLoadingState { self.view?.state(.loading) }
        
        self.view?.set(retryBlock: { self.fetchContent(matchingString: searchString, showLoadingState: showLoadingState) })
        
        self.contentListInteractor.contentList(matchingString: searchString)
    }
    
    fileprivate func handleContentListResult(_ result: ContentListResult, contentTrigger: ContentTrigger) {
        let oldContents = self.contents
        // If the response is success, set the contents downloaded
        switch result {
        case .success(let contentList):
            self.contents = contentList.contents
        default: break
        }
        // Check the source to update the content or show a message
        switch contentTrigger {
        case .refresh:
            self.show(contentListResponse: result, contentTrigger: contentTrigger)
        default:
            if oldContents.count == 0 {
                self.show(contentListResponse: result, contentTrigger: contentTrigger)
            } else if oldContents != self.contents {
                self.view?.showNewContentAvailableView(with: self.contents)
            } else {
                self.view?.reloadVisibleContent()
            }
        }
        self.viewDataStatus = .canReload
    }
    
    private func show(contentListResponse: ContentListResult, contentTrigger: ContentTrigger) {
        switch contentListResponse {
        case .success(let contentList):
            self.show(contentList: contentList, contentTrigger: contentTrigger)
        case .empty:
            self.showEmptyContentView(forTrigger: contentTrigger)
        case .cancelled:
            self.view?.stopRefreshControl()
        case .error:
            self.view?.show(error: kLocaleOcmErrorContent)
            self.view?.state(.error)
        }
    }

    private func show(contentList: ContentList, contentTrigger: ContentTrigger) {
        self.view?.layout(contentList.layout)
        
        var contentsToShow = contentList.contents
        
        if let tags = self.currentFilterTags {
            contentsToShow = contentsToShow.filter(byTags: tags)
        }
        
        self.show(contents: contentsToShow, contentTrigger: contentTrigger)
    }
    
    private func show(contents: [Content], contentTrigger: ContentTrigger) {
        if contents.isEmpty {
            self.showEmptyContentView(forTrigger: contentTrigger)
        } else {
            self.view?.show(contents)
            self.view?.state(.showingContent)
            self.contentListDidLoad()
        }
    }
    
    private func showEmptyContentView(forTrigger contentTrigger: ContentTrigger) {
        switch contentTrigger {
        case .initialContent, .refresh, .updateNeeded:
            self.view?.state(.noContent)
        case .search:
            self.view?.state(.noSearchResults)
        }
    }
    
    private func openContent(_ content: Content, in viewController: UIViewController) {
        // Notified when user opens a content
        self.ocm.delegate?.userDidOpenContent(with: content.elementUrl)
        self.ocm.eventDelegate?.userDidOpenContent(identifier: content.elementUrl, type: Content.contentType(of: content.elementUrl) ?? "")
        self.contentListInteractor.action(forcingDownload: false, with: content.elementUrl) { action, _ in
            guard var actionUpdate = action else { logWarn("Action is nil"); return }
            actionUpdate.output = self
            ActionInteractor().run(action: actionUpdate, viewController: viewController)
        }
    }
    
    private func contentListDidLoad() {
        self.contentListInteractor.traceSectionLoadForContentList()
    }
    
    private func clearContent() {
        self.view?.show([])
    }
    
}

// MARK: - ContentListInteractorOutput

extension ContentListPresenter: ContentListInteractorOutput {
    
    func contentListLoaded(_ result: ContentListResult) {
        self.handleContentListResult(result, contentTrigger: self.contentTrigger ?? .updateNeeded)
        self.contentTrigger = nil
    }
    
}

// MARK: - ActionOut

extension ContentListPresenter: ActionOut {
    
    func blockView() {
        self.view?.displaySpinner(show: true)
    }
    
    func unblockView() {
        self.view?.displaySpinner(show: false)
    }
}
