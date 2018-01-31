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
    func showAlert(_ message: String)
}

protocol ArticlePresenterInput {
    
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDesappear()
    func viewDidAppear()
    func performAction(of element: Element, with info: Any)
    func configure(element: Element)
    func title() -> String?
    func containerScrollViewDidScroll(_ scrollView: UIScrollView)
}

class ArticlePresenter: NSObject, ArticleInteractorOutput {

    let article: Article
    weak var view: ArticleUI?

    let actionInteractor: ActionInteractorProtocol
    let refreshManager: RefreshManager
    let reachability: ReachabilityInput
    let ocm: OCM
    let actionScheduleManager: ActionScheduleManager
    let articleInteractor: ArticleInteractorProtocol
    var videoInteractor: VideoInteractor?
    
    // MARK: - Private attributes
    
    private var loaded = false
    
    // MARK: Refreshable
    
    var viewDataStatus: ViewDataStatus = .canReload
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    init(article: Article, view: ArticleUI, actionInteractor: ActionInteractorProtocol, articleInteractor: ArticleInteractorProtocol, ocm: OCM, actionScheduleManager: ActionScheduleManager, refreshManager: RefreshManager, reachability: ReachabilityInput, videoInteractor: VideoInteractor? = nil) {
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
    
    // MARK: - ArticleInteractorOutput
    
    func showViewForAction(_ action: Action) {
        self.view?.showViewForAction(action)
    }
    
    func showAlert(_ message: String) {
        self.view?.showAlert(message)
    }
    
    func showVideo(_ video: Video, in player: VideoPlayerProtocol?) {
        guard self.reachability.isReachable() else {
            logWarn("isReachable is nil")
            return
        }
        var viewController: UIViewController?
        switch video.format {
        case .youtube:
            viewController = self.ocm.wireframe.loadYoutubeVC(with: video.source)
        default:
            player?.toFullScreen(nil)
        }
        if let viewController = viewController {
            self.ocm.wireframe.show(viewController: viewController)
            self.ocm.eventDelegate?.videoDidLoad(identifier: video.source)
        }
    }
    
    fileprivate func reproduceVisibleVideo() {
        let visibleVideos = self.visibleVideos()
        if visibleVideos.count > 0 {
            if let video = visibleVideos.first, !video.isPlaying() {
                video.play()
            }
        }
    }
    
    fileprivate func pauseNoVisibleVideos() {
        let noVisibleVideos = self.noVisibleVideos()
        noVisibleVideos.forEach { video in
            video.pause()
        }
    }
    
    fileprivate func visibleVideos() -> [ElementVideo] {
        return self.article.elements.flatMap { element -> (ElementVideo?) in
            if let elementVideo = element as? ElementVideo, elementVideo.isVisible() {
                return elementVideo
            }
            return nil
        }
    }
    
    fileprivate func noVisibleVideos() -> [ElementVideo] {
        return self.article.elements.flatMap { element -> (ElementVideo?) in
            if let elementVideo = element as? ElementVideo, !elementVideo.isVisible() {
                return elementVideo
            }
            return nil
        }
    }
}

// MARK: - ArticlePresenterInput

extension ArticlePresenter: ArticlePresenterInput {
    
    func viewDidLoad() {
        self.articleInteractor.traceSectionLoadForArticle()
        self.refreshManager.registerForNetworkChanges(self)
    }
    
    func viewWillAppear() {
        if !self.loaded {
            self.loaded = true
            self.view?.show(article: self.article)
        } else {
            // self.view?.update(with: self.article)
        }
    }
    
    func viewDidAppear() {
        self.reproduceVisibleVideo()
    }
    
    func viewWillDesappear() {
        self.article.elements.flatMap({ $0 as? ElementVideo }).forEach { video in
            video.pause()
        }
    }
    
    func performAction(of element: Element, with info: Any) {            
        self.articleInteractor.action(of: element, with: info)
    }
    
    func configure(element: Element) {
        if let elementVideo = element as? ElementVideo {
            self.videoInteractor?.loadVideoInformation(for: elementVideo.video)
        }
    }
    
    func title() -> String? {
        return self.article.name
    }
    
    func containerScrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pauseNoVisibleVideos()
        self.reproduceVisibleVideo()
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
                elementVideo.configure(with: [
                    "video": video 
                ])
            }
        }
        self.pauseNoVisibleVideos()
        self.reproduceVisibleVideo()
    }
}

// MARK: - ActionOutput

extension ArticlePresenter: ActionOutput {
    
    func blockView() {
        self.view?.displaySpinner(show: true)
    }
    
    func unblockView() {
        self.view?.displaySpinner(show: false)
    }
}
