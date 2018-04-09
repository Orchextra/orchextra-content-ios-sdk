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
    let ocm: OCM
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
    
    func actionLoadingDidFinishWithAction(_ action: Action) {
        self.view?.showViewForAction(action)
    }
    
    func actionLoadingDidFinishWithError(_ error: Error) {
        self.view?.showAlert(error.localizedDescription)
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
            if let player = player {
                player.toFullScreen(nil)
            } else {
                viewController = self.ocm.wireframe.loadVideoPlayerVC(with: video)
            }
        }
        if let viewController = viewController {
            self.ocm.wireframe.show(viewController: viewController)
            self.ocm.eventDelegate?.videoDidLoad(identifier: video.source)
        }
    }
    
    func willExecuteAction(_ action: Action) {
        
    }
    
    // MARK: - Private methods
    
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
        return self.article.elements.compactMap { element -> (ElementVideo?) in
            if let elementVideo = element as? ElementVideo, elementVideo.isVisible() {
                return elementVideo
            }
            return nil
        }
    }
    
    fileprivate func noVisibleVideos() -> [ElementVideo] {
        return self.article.elements.compactMap { element -> (ElementVideo?) in
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
        } else {
            self.refreshElements()
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
        if videoPlayer.status == .playing {
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
        self.refreshElements()
        self.view?.dismissLoadingIndicator()
    }
    
    func refreshElements() {
        for element in self.article.elements {
            if let refreshableElement = element as? RefreshableElement {
                refreshableElement.update()
            }
        }
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

// MARK: - FederableActionDelegate

extension ArticlePresenter: FederableActionDelegate {
    
    func willStartFederatedAuthentication() {
        self.view?.displaySpinner(show: true)
    }
    
    func didFinishFederatedAuthentication() {
        self.view?.displaySpinner(show: false)
    }
}
