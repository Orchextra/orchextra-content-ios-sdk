//
//  ContentListPresenter.swift
//  OCM
//
//  Created by José Estela on 22/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class Pagination {
    
    var current: Int = 1
    var itemsPerPage: Int
    
    init(itemsPerPage: Int) {
        self.itemsPerPage = itemsPerPage
    }
    
    func reset() {
        self.current = 1
    }
}

protocol ContentListUI: class {
    func showLoadingView(_ show: Bool)
    func showLoadingViewForAction(_ show: Bool)
    func showErrorView(_ show: Bool)
    func showNoContentView(_ show: Bool)
    func dismissPaginationControlView()
    func cleanContents()
    func showContents(_ contents: [Content], layout: Layout)
    func appendContents(_ contents: [Content], completion: @escaping () -> Void)
    func showAlert(_ message: String)
    func showNewContentAvailableView()
    func dismissNewContentAvailableView()
    func enablePagination()
    func disablePagination()
}

class ContentListPresenter: ContentListInteractorOutput {    
    
    // MARK: - Public attributes
    
    weak var view: ContentListUI?
    let wireframe: ContentListWireframeInput
    var contentListInteractor: ContentListInteractorProtocol
    var contentList: ContentList?
    let reachability: ReachabilityInput
    let ocm: OCM
    var pagination = Pagination(itemsPerPage: 7) // !!!
    
    // MAKR: - Private attributes
    
    private var currentFilterTags: [String]?
    
    init(view: ContentListUI, wireframe: ContentListWireframeInput, contentListInteractor: ContentListInteractorProtocol, reachability: ReachabilityInput, ocm: OCM) {
        self.view = view
        self.wireframe = wireframe
        self.contentListInteractor = contentListInteractor
        self.reachability = reachability
        self.ocm = ocm
    }
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        self.view?.showNoContentView(false)
        self.view?.showErrorView(false)
        self.view?.cleanContents()
        self.view?.showLoadingView(true)
        self.contentListInteractor.output = self
        self.view?.enablePagination()
        self.contentListInteractor.contentList(forcingDownload: false, page: 1, items: self.pagination.itemsPerPage * 2) //!!! 666
    }
    
    func userDidSelectContent(_ content: Content, in viewController: UIViewController) {
        // Notified when user opens a content
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
        if let contentList = self.contentList {
            let filteredContents = self.showFilteredContents(contentList.contents)
            if filteredContents.count > 0 {
                self.view?.showContents(filteredContents, layout: contentList.layout)
            } else {
                self.view?.showNoContentView(true)
            }
        }
    }
    
    func userDidRefresh() {
        self.pagination.reset() // !!!
        self.view?.enablePagination()
        self.contentListInteractor.contentList(forcingDownload: true, page: 1, items: self.pagination.itemsPerPage * 2) // !!! 666
    }
    
    func userDidPaginate() {
        delay(0.5) { // Just for showing the indicator
            self.contentListInteractor.contentList(forcingDownload: true, page: self.pagination.current, items: self.pagination.itemsPerPage) // !!! Here we have to send the next page
        }
    }
    
    // MARK: - Private methods
    
    private func showFilteredContents(_ contents: [Content]) -> [Content] {
        if let tags = self.currentFilterTags {
            return contents.filter(byTags: tags)
        }
        return contents
    }
    
    private func openContent(_ content: Content, in viewController: UIViewController) {
        self.ocm.delegate?.userDidOpenContent(with: content.elementUrl)
        self.ocm.eventDelegate?.userDidOpenContent(identifier: content.elementUrl, type: Content.contentType(of: content.elementUrl) ?? "")
        self.contentListInteractor.action(forcingDownload: false, with: content.elementUrl) { action, _ in
            guard var actionUpdate = action else { logWarn("Action is nil"); return }
            actionUpdate.output = self
            self.wireframe.showAction(actionUpdate, in: viewController)
        }
    }
    
    // MARK: - ContentListInteractorOutput
    
    func contentListLoaded(_ result: ContentListResult) {
        self.view?.showLoadingView(false)
        switch result {
        case .success(contents: let contentList):
            if self.pagination.current == 1 {
                self.contentList = contentList
                self.view?.showContents(self.showFilteredContents(contentList.contents), layout: contentList.layout)
            } else if let currentContentList = self.contentList {
                self.contentList = ContentList(
                    contents: currentContentList.contents + contentList.contents,
                    layout: currentContentList.layout,
                    expiredAt: currentContentList.expiredAt,
                    contentVersion: currentContentList.contentVersion
                )
                self.view?.appendContents(contentList.contents) {
                    self.view?.dismissPaginationControlView()
                }
            }
            self.pagination.current += Int(contentList.contents.count / self.pagination.itemsPerPage)
            if contentList.contents.count < self.pagination.itemsPerPage {
                self.view?.disablePagination()
            }
        case .cancelled:
            self.view?.showNoContentView(true)
        case .empty:
            self.view?.showNoContentView(true)
        case .error:
            self.view?.showErrorView(true)
        }
    }
    
    func newContentAvailable() {
        self.view?.showNewContentAvailableView()
    }
    
    func itemsPerContentListPage() -> Int {
        return self.pagination.itemsPerPage
    }
    
}

extension ContentListPresenter: ActionOutput {
    
    func blockView() {
        self.view?.showLoadingView(true)
    }
    
    func unblockView() {
        self.view?.showLoadingView(false)
    }
}
