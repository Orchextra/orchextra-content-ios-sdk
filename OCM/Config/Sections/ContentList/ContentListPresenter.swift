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
    func showLoadingView()
    func dismissLoadingView()
    func showLoadingViewForAction(_ show: Bool)
    func showErrorView(_ show: Bool)
    func showNoContentView(_ show: Bool)
    func dismissPaginationView(_ completion: (() -> Void)?)
    func cleanContents()
    func showContents(_ contents: [Content], layout: Layout)
    func appendContents(_ contents: [Content], completion: (() -> Void)?)
    func showNewContentAvailableView()
    func dismissNewContentAvailableView()
    func enablePagination()
    func disablePagination()
    func disableRefresh()
    func enableRefresh()
}

class ContentListPresenter: ContentListInteractorOutput {    
    
    // MARK: - Public attributes
    
    weak var view: ContentListUI?
    let wireframe: ContentListWireframeInput
    var contentListInteractor: ContentListInteractorProtocol
    var contentList: ContentList?
    let ocm: OCM
    let actionScheduleManager: ActionScheduleManager
    let actionInteractor: ActionInteractorProtocol
    let pagination: Pagination
    
    // MAKR: - Private attributes
    
    private var currentFilterTags: [String]?
    
    init(view: ContentListUI, wireframe: ContentListWireframeInput, contentListInteractor: ContentListInteractorProtocol, ocm: OCM, actionScheduleManager: ActionScheduleManager, actionInteractor: ActionInteractorProtocol) {
        self.view = view
        self.wireframe = wireframe
        self.contentListInteractor = contentListInteractor
        self.actionInteractor = actionInteractor
        self.ocm = ocm
        if let paginationConfig = Config.paginationConfig {
            self.pagination = Pagination(itemsPerPage: paginationConfig.items)
        } else {
            self.pagination = Pagination(itemsPerPage: 9)
        }
        self.actionScheduleManager = actionScheduleManager
        self.contentListInteractor.output = self
    }
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        self.view?.showNoContentView(false)
        self.view?.showErrorView(false)
        self.view?.cleanContents()
        self.view?.showLoadingView()
        self.contentListInteractor.output = self
        self.view?.enablePagination()
        self.contentListInteractor.contentList(forcingDownload: false, page: 1, items: self.pagination.itemsPerPage * 2)
    }
    
    func userDidSelectContent(_ content: Content, viewController: UIViewController) {
        self.openContent(content, in: viewController)
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
        self.view?.disablePagination()
        self.pagination.reset()
        self.contentListInteractor.contentList(forcingDownload: true, page: 1, items: self.pagination.itemsPerPage * 2)
    }
    
    func userDidTapInNewContentAvailable() {
        self.view?.cleanContents()
        self.view?.showLoadingView()
        self.userDidRefresh()
    }
    
    func userDidPaginate() {
        self.view?.disableRefresh()
        self.contentListInteractor.contentList(forcingDownload: false, page: self.pagination.current, items: self.pagination.itemsPerPage)
    }
    
    // MARK: - Private methods
    
    private func showFilteredContents(_ contents: [Content]) -> [Content] {
        if let tags = self.currentFilterTags {
            return contents.filter(byTags: tags)
        }
        return contents
    }
    
    private func openContent(_ content: Content, in viewController: UIViewController) {
        self.contentListInteractor.action(forcingDownload: false, with: content.elementUrl) { action, error in
            if let action = action {
                self.ocm.delegate?.userDidOpenContent(with: content.elementUrl)
                self.ocm.eventDelegate?.userDidOpenContent(identifier: content.elementUrl, type: Content.contentType(of: content.elementUrl) ?? "")
                if var federableAction = action as? FederableAction {
                    federableAction.federateDelegate = self
                }
                self.actionInteractor.run(action: action, viewController: viewController)
            } else if error != nil {
                self.ocm.errorDelegate?.openContentFailed(with: OCMError.openContentWithNoInternet)
            }
        }
    }
    
    // MARK: - ContentListInteractorOutput
    
    func contentListLoaded(_ result: ContentListResult) {
        self.view?.enableRefresh()
        self.view?.dismissLoadingView()
        switch result {
        case .success(contents: let contentList):
            self.handleContentListResult(contentList)
        case .empty:
            if self.contentList != nil {
                self.view?.dismissPaginationView(nil)
                self.view?.disablePagination()
            } else {
                self.view?.showNoContentView(true)
            }
        case .error:
            if self.contentList == nil {
                self.view?.showErrorView(true)
            } else {
                self.view?.dismissPaginationView(nil)
            }
        }
    }
    
    func newContentAvailable() {
        self.view?.showNewContentAvailableView()
    }
    
    func numberOfItemsPerPage() -> Int {
        return self.pagination.itemsPerPage
    }
    
    // MARK: - Private methods
    
    private func handleContentListResult(_ contentList: ContentList) {
        if self.pagination.current == 1 {
            self.contentList = contentList
            let numberOfContents = Double(contentList.contents.count)
            let itemsPerPage = Double(self.pagination.itemsPerPage)
            self.pagination.current += Int((numberOfContents / itemsPerPage).rounded(.up))
            if let contentList = self.contentList, let numberOfItems = contentList.numberOfItems {
                if contentList.contents.count >= numberOfItems {
                    self.view?.disablePagination()
                } else {
                    self.view?.enablePagination()
                }
            } else {
                self.view?.enablePagination()
            }
            self.view?.showContents(self.showFilteredContents(contentList.contents), layout: contentList.layout)
        } else if let currentContentList = self.contentList {
            self.contentList = ContentList(
                from: currentContentList,
                byAppendingContents: contentList.contents,
                numberOfItems: contentList.numberOfItems
            )
            let numberOfContents = Double(contentList.contents.count)
            let itemsPerPage = Double(self.pagination.itemsPerPage)
            self.pagination.current += Int((numberOfContents / itemsPerPage).rounded(.up))
            if let contentList = self.contentList, let numberOfItems = contentList.numberOfItems {
                if contentList.contents.count >= numberOfItems {
                    self.view?.disablePagination()
                }
            }
            self.view?.dismissPaginationView {
                self.view?.appendContents(contentList.contents, completion: nil)
            }
        }
    }
}

// MARK: - FederableActionDelegate

extension ContentListPresenter: FederableActionDelegate {
    
    func willStartFederatedAuthentication() {
        self.view?.showLoadingView()
    }
    
    func didFinishFederatedAuthentication() {
        self.view?.dismissLoadingView()
    }
}
