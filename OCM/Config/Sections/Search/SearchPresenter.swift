//
//  SearchPresenter.swift
//  OCM
//
//  Created by José Estela on 21/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

protocol SearchUI: class {
    func showLoadingView(_ show: Bool)
    func showLoadingViewForAction(_ show: Bool)
    func showErrorView(_ show: Bool)
    func showNoResultsView(_ show: Bool)
    func cleanContents()
    func showContents(_ contents: [Content], layout: Layout)
    func showAlert(_ message: String)
}

class SearchPresenter: ContentListInteractorOutput {
    
    // MARK: - Public attributes
    
    weak var view: SearchUI?
    let wireframe: SearchWireframeInput
    var contentListInteractor: ContentListInteractorProtocol
    var contentList: ContentList?
    let reachability: ReachabilityInput
    let ocm: OCM
    
    init(view: SearchUI, wireframe: SearchWireframeInput, contentListInteractor: ContentListInteractorProtocol, reachability: ReachabilityInput, ocm: OCM) {
        self.view = view
        self.wireframe = wireframe
        self.contentListInteractor = contentListInteractor
        self.reachability = reachability
        self.ocm = ocm
    }
    
    // MARK: - Input methods
    
    func viewDidLoad() {
        self.contentListInteractor.output = self
    }
    
    func userDidSearch(byString string: String) {
        self.view?.showNoResultsView(false)
        self.view?.showErrorView(false)
        self.view?.cleanContents()
        self.view?.showLoadingView(true)
        self.contentListInteractor.contentList(matchingString: string)
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
            self.contentList = contentList
            self.view?.showContents(contentList.contents, layout: contentList.layout)
        case .cancelled:
            self.view?.showNoResultsView(true)
        case .empty:
            self.view?.showNoResultsView(true)
        case .error:
            self.view?.showErrorView(true)
        }
    }
}

extension SearchPresenter: ActionOutput {
    
    func blockView() {
        self.view?.showLoadingView(true)
    }
    
    func unblockView() {
        self.view?.showLoadingView(false)
    }
}
