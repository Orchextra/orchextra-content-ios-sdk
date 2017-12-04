//
//  ArticlePresenter.swift
//  OCM
//
//  Created by Judith Medina on 19/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol ArticleUI: class {
    func show(article: Article)
    func update(with article: Article)
    func showViewForAction(_ action: Action)
    func showLoadingIndicator()
    func dismissLoadingIndicator()
    func displaySpinner(show: Bool)
}

class ArticlePresenter: NSObject {

    let article: Article
    weak var view: ArticleUI?
    let actionInteractor: ActionInteractorProtocol
    let refreshManager: RefreshManager
    let reachability: ReachabilityInput
    let ocm: OCM
    let actionScheduleManager: ActionScheduleManager
    let articleInteractor: ArticleInteractor
    var videoInteractor: VideoInteractor?
    
    // MARK: - Private attributes
    
    private var loaded = false
    
    // MARK: Refreshable
    
    var viewDataStatus: ViewDataStatus = .canReload
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    init(article: Article, view: ArticleUI, actionInteractor: ActionInteractorProtocol, articleInteractor: ArticleInteractor, ocm: OCM, actionScheduleManager: ActionScheduleManager, refreshManager: RefreshManager, reachability: ReachabilityInput, videoInteractor: VideoInteractor? = nil) {
        self.article = article
        self.view = view
        self.actionInteractor = actionInteractor
        self.videoInteractor = videoInteractor
        self.ocm = ocm
        self.reachability = reachability
        self.refreshManager = refreshManager
        self.actionScheduleManager = actionScheduleManager
        self.articleInteractor = articleInteractor
    }
    
    func viewDidLoad() {
        self.articleInteractor.traceSectionLoadForArticle()
        self.refreshManager.registerForNetworkChanges(self)
    }
    
    func viewWillAppear() {
        if !self.loaded {
            self.loaded = true
            self.view?.show(article: self.article)
        } else {
            self.view?.update(with: self.article)
        }
    }
    
    func performAction(of element: Element, with info: Any) {
        if element is ElementButton {
            self.performButtonAction(info)
        } else if element is ElementRichText {
            self.performRichTextAction(info)
        } else if element is ElementVideo {
            self.performVideoAction(info)
        }
    }
    
    func configure(element: Element) {
        if let elementVideo = element as? ElementVideo {
            self.videoInteractor?.loadVideoInformation(for: elementVideo.video)
        }
    }
    
    // MARK: Helpers
    
    private func performButtonAction(_ info: Any) {
        // Perform button's action
        if let action = info as? String {
            self.actionInteractor.action(forcingDownload: false, with: action) { action, _ in
                if var unwrappedAction = action {
                    if let elementUrl = unwrappedAction.elementUrl, !elementUrl.isEmpty {
                        self.ocm.eventDelegate?.userDidOpenContent(identifier: elementUrl, type: unwrappedAction.type ?? "")
                    }else if let slug = unwrappedAction.slug, !slug.isEmpty {
                        self.ocm.eventDelegate?.userDidOpenContent(identifier: slug, type: unwrappedAction.type ?? "")
                    }
                    
                    if unwrappedAction.view() != nil {
                        self.view?.showViewForAction(unwrappedAction)
                    }else {
                        unwrappedAction.output = self
                        unwrappedAction.executable()
                    }
                }
            }
        }
    }
    
    private func performRichTextAction(_ info: Any) {
        // Open hyperlink's URL on web view
        if let URL = info as? URL {
            // Open on Safari VC
            self.ocm.wireframe.showBrowser(url: URL)
        }
    }
    
    private func performVideoAction(_ info: Any) {
        if let video = info as? Video {
            guard self.reachability.isReachable() else { logWarn("isReachable is nil"); return }
            var viewController: UIViewController?
            switch video.format {
            case .youtube:
                viewController = self.ocm.wireframe.loadYoutubeVC(with: video.source)
            default:
                viewController = self.ocm.wireframe.loadVideoPlayerVC(with: video)
            }
            if let viewController = viewController {
                self.ocm.wireframe.show(viewController: viewController)
                self.ocm.eventDelegate?.videoDidLoad(identifier: video.source)
            }
        }
    }
}

// MARK: - Refreshable

extension ArticlePresenter: Refreshable {
    
    func refresh() {
        self.view?.showLoadingIndicator()
        self.view?.update(with: self.article)
        self.view?.dismissLoadingIndicator()
    }
}

// MARK: - VideoInteractorOutput

extension ArticlePresenter: VideoInteractorOutput {
    
    func videoInformationLoaded(_ video: Video?) {
        for element in self.article.elements {
            if let elementVideo = element as? ElementVideo, let video = video, elementVideo.video == video {
                elementVideo.update(with: [
                    "video": video 
                ])
            }
        }
    }
}

// MARK: - ActionOut

extension ArticlePresenter: ActionOut {
    
    func blockView() {
        self.view?.displaySpinner(show: true)
    }
    
    func unblockView() {
        self.view?.displaySpinner(show: false)
    }
}
