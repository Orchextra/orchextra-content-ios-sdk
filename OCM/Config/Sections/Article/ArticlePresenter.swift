//
//  ArticlePresenter.swift
//  OCM
//
//  Created by Judith Medina on 19/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol PArticleVC: class {
    func show(article: Article)
    func update(with article: Article)
    func showViewForAction(_ action: Action)
    func showLoadingIndicator()
    func dismissLoadingIndicator()
    func displaySpinner(show: Bool)
}

class ArticlePresenter: NSObject, Refreshable {

    let article: Article
    weak var viewer: PArticleVC?
    let videoInteractor: VideoInteractor
    let actionInteractor: ActionInteractor
    let refreshManager = RefreshManager.shared
    var loaded = false
    var viewDataStatus: ViewDataStatus = .canReload
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    init(article: Article, actionInteractor: ActionInteractor, videoInteractor: VideoInteractor, reachability: ReachabilityWrapper) {
        self.article = article
        self.actionInteractor = actionInteractor
        self.videoInteractor = videoInteractor
    }
    
    func viewDidLoad() {
        self.refreshManager.registerForNetworkChanges(self)
    }
    
    func viewWillAppear() {
        if !self.loaded {
            self.loaded = true
            self.viewer?.show(article: self.article)
        } else {
            self.viewer?.update(with: self.article)
        }
    }
    
    func performAction(of element: Element, with info: Any) {
        if element is ElementButton {
            // Perform button's action
            if let action = info as? String {
                self.actionInteractor.action(with: action) { action, _ in
                    if action?.view() != nil, let unwrappedAction = action {
                        self.viewer?.showViewForAction(unwrappedAction)
                    } else {
                        var actionUpdate = action
                        actionUpdate?.output = self
                        actionUpdate?.executable()
                    }
                }
            }
        } else if element is ElementRichText {
            // Open hyperlink's URL on web view
            if let URL = info as? URL {
                // Open on Safari VC
                OCM.shared.wireframe.showBrowser(url: URL)
            }
        } else if element is ElementVideo {
            if let video = info as? Video {
                guard
                    ReachabilityWrapper.shared.isReachable()
                else {
                    return
                }
                var viewController: UIViewController? = nil
                switch video.format {
                case .youtube:
                    viewController = OCM.shared.wireframe.showYoutubeVC(videoId: video.source)
                default:
                    viewController = OCM.shared.wireframe.showVideoPlayerVC(with: video)
                }
                if let viewController = viewController {
                    OCM.shared.wireframe.show(viewController: viewController)
                    OCM.shared.analytics?.track(with: [
                        AnalyticConstants.kContentType: AnalyticConstants.kVideo,
                        AnalyticConstants.kValue: video.source
                    ])
                }
            }
        }
    }
    
    func configure(element: Element) {
        if let elementVideo = element as? ElementVideo {
            self.videoInteractor.loadVideoInformation(for: elementVideo.video)
        }
    }
    
    // MARK: - Refreshable
    
    func refresh() {
        self.viewer?.showLoadingIndicator()
        self.viewer?.update(with: self.article)
        self.viewer?.dismissLoadingIndicator()
    }
}

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
        self.viewer?.displaySpinner(show: true)
    }
    
    func unblockView() {
        self.viewer?.displaySpinner(show: false)
    }
}
