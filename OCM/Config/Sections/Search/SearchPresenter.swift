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
    func showLoadingView()
    func dismissLoadingView()
    func showLoadingViewForAction(_ show: Bool)
    func showErrorView(_ show: Bool)
    func showNoResultsView(_ show: Bool)
    func cleanContents()
    func showContents(_ contents: [Content], layout: Layout)
}

class SearchPresenter: SearchInteractorOutput {
    
    // MARK: - Public attributes
    
    weak var view: SearchUI?
    let wireframe: SearchWireframeInput
    var actionInteractor: ActionInteractorProtocol
    var searchInteractor: SearchInteractorInput
    var contentList: ContentList?
    let reachability: ReachabilityInput
    let ocmController: OCMController
    
    init(view: SearchUI, wireframe: SearchWireframeInput, actionInteractor: ActionInteractorProtocol, searchInteractor: SearchInteractorInput, reachability: ReachabilityInput, ocmController: OCMController) {
        self.view = view
        self.wireframe = wireframe
        self.actionInteractor = actionInteractor
        self.searchInteractor = searchInteractor
        self.reachability = reachability
        self.ocmController = ocmController
    }
    
    // MARK: - Input methods
    
    func userDidSearch(byString string: String) {
        self.view?.showNoResultsView(false)
        self.view?.showErrorView(false)
        self.view?.cleanContents()
        self.view?.showLoadingView()
        self.searchInteractor.searchContentList(by: string)
    }
    
    func userDidSelectContent(_ content: Content, in viewController: UIViewController) {
        // Notified when user opens a content
        if self.reachability.isReachable() {
            self.openContent(content, in: viewController)
        } else if Config.offlineSupportConfig != nil, ContentCacheManager.shared.cachedArticle(for: content.elementUrl) != nil {
            self.openContent(content, in: viewController)
        } else {
            self.ocmController.errorDelegate?.openContentFailed(with: OCMError.openContentWithNoInternet)
        }
    }
    
    private func openContent(_ content: Content, in viewController: UIViewController) {
        self.actionInteractor.action(forcingDownload: false, with: content.elementUrl) { action, error in
            if let action = action {
                self.ocmController.contentDelegate?.userDidOpenContent(with: content.elementUrl)
                self.ocmController.eventDelegate?.userDidOpenContent(identifier: content.elementUrl, type: Content.contentType(of: content.elementUrl) ?? "")
                if var federableAction = action as? FederableAction {
                    federableAction.federateDelegate = self
                }
                self.wireframe.showAction(action, in: viewController)
            } else if error != nil {
                self.ocmController.errorDelegate?.openContentFailed(with: OCMError.openContentWithNoInternet)
            }
        }
    }
    
    // MARK: - SearchInteractorOutput
    
    internal func contentListLoaded(_ result: ContentListResult) {
        self.view?.dismissLoadingView()
        switch result {
        case .success(contents: let contentList):
            self.contentList = contentList
            self.view?.showContents(contentList.contents, layout: contentList.layout)
        case .empty:
            self.view?.showNoResultsView(true)
        case .error:
            self.view?.showErrorView(true)
        }
    }
}

extension SearchPresenter: FederableActionDelegate {
    
    func willStartFederatedAuthentication() {
        self.view?.showLoadingView()
    }
    
    func didFinishFederatedAuthentication() {
        self.view?.dismissLoadingView()
    }
}
