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
    func showViewForAction(_ action: Action)
    func showLoadingIndicator()
    func dismissLoadingIndicator()
    func displaySpinner(show: Bool)
    func showAlert(_ message: String)
}

protocol ArticlePresenterInput {
    
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func performAction(of element: Element, with info: Any)
    func configure(element: Element)
    func title() -> String?
    func containerScrollViewDidScroll(_ scrollView: UIScrollView)
    func soundStatus(for: Element) -> Bool
    func enableSound(for: Element)
}

class ArticlePresenter: NSObject, ArticleInteractorOutput {

    let article: Article
    weak var view: ArticleUI?

    let actionInteractor: ActionInteractorProtocol
    let refreshManager: RefreshManager
    let reachability: ReachabilityInput
    let ocmController: OCMController
    let actionScheduleManager: ActionScheduleManager
    let articleInteractor: ArticleInteractorProtocol
    var videoInteractor: VideoInteractor?
    
    // MARK: - Private attributes
    
    private var loaded = false
    private var soundStatus = false
    
    // MARK: Refreshable
    
    var viewDataStatus: ViewDataStatus = .canReload
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    init(article: Article, view: ArticleUI, actionInteractor: ActionInteractorProtocol, articleInteractor: ArticleInteractorProtocol, ocmController: OCMController, actionScheduleManager: ActionScheduleManager, refreshManager: RefreshManager, reachability: ReachabilityInput, videoInteractor: VideoInteractor? = nil) {
        self.article = article
        self.view = view
        self.actionInteractor = actionInteractor
        self.videoInteractor = videoInteractor
        self.ocmController = ocmController
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
            viewController = self.ocmController.wireframe?.loadYoutubeVC(with: video.source)
        default:
            if let player = player {
                player.toFullScreen(nil)
            } else {
                viewController = self.ocmController.wireframe?.loadVideoPlayerVC(with: video)
            }
        }
        if let viewController = viewController {
            self.ocmController.wireframe?.show(viewController: viewController)
            self.ocmController.eventDelegate?.videoDidLoad(identifier: video.source)
        }
    }
    
    fileprivate func reproduceVisibleVideo(isScrolling: Bool) {
        let visibleVideos = self.visibleVideos()
        if visibleVideos.count > 0 {
            if let video = visibleVideos.first, !video.isPlaying() {
                
                video.addVideos()
                video.delegate = self
                
                if isScrolling || video.videoView?.videoPlayer?.videoStatus() == .undefined {
                    video.play()
                }
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
            self.view?.show(article: self.article)
        }
    }
    
    func viewDidAppear() {
        self.loaded = true
        self.reproduceVisibleVideo(isScrolling: false)
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
        self.reproduceVisibleVideo(isScrolling: true)
    }
}

// MARK: - Refreshable

extension ArticlePresenter: ElementVideoDelegate {
    func videoPlayerDidExitFromFullScreen(_ videoPlayer: VideoPlayer) {
        if #available(iOS 11, *), videoPlayer.status == .playing {
            videoPlayer.play()
        }
    }
    
    func soundStatus(for: Element) -> Bool {
        return self.soundStatus
    }
    
    func enableSound(for: Element) {
        let soundStatus = self.soundStatus
        self.soundStatus = !soundStatus
    }
}

// MARK: - Refreshable

extension ArticlePresenter: Refreshable {
    
    func refresh() {
        self.view?.showLoadingIndicator()
        for element in self.article.elements {
            if let refreshableElement = element as? RefreshableElement {
                refreshableElement.update()
            }
        }
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
        if self.loaded {
            self.pauseNoVisibleVideos()
            self.reproduceVisibleVideo(isScrolling: false)
        }
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
