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

class ArticlePresenter: NSObject {

    let article: Article
    weak var viewer: PArticleVC?
    var videoInteractor: VideoInteractor?
    let actionInteractor: ActionInteractor
    let refreshManager = RefreshManager.shared
    var loaded = false
    var viewDataStatus: ViewDataStatus = .canReload
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    init(article: Article, actionInteractor: ActionInteractor, reachability: ReachabilityWrapper, videoInteractor: VideoInteractor? = nil) {
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
            self.actionInteractor.action(with: action) { action, error in                
                guard let action = action else {
                    guard let error = error?._userInfo?["OCM_ERROR_MESSAGE"] as? String else {
                        logWarn("Action and error is Nil")
                        return
                    }
                    
                    if error == "requiredAuth" {
                        OCM.shared.delegate?.contentRequiresUserAuthentication {
                            if Config.isLogged {
                                // Maybe the Orchextra login doesn't finish yet, so
                                // We save the pending action to perform when the login did finish
                                // If the user is already logged in, the action will be performed automatically
                                ActionScheduleManager.shared.registerAction(for: .login) { [unowned self] in
                                    self.performButtonAction(info)
                                }
                            }
                        }
                    }
                    return
                }
                
                if action.view() != nil {
                    self.viewer?.showViewForAction(action)
                } else {
                    var actionUpdate = action
                    actionUpdate.output = self
                    actionUpdate.executable()
                }
            }
        }
    }
    
    private func performRichTextAction(_ info: Any) {
        // Open hyperlink's URL on web view
        if let URL = info as? URL {
            // Open on Safari VC
            OCM.shared.wireframe.showBrowser(url: URL)
        }
    }
    
    private func performVideoAction(_ info: Any) {
        if let video = info as? Video {
            guard ReachabilityWrapper.shared.isReachable() else { return }
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

// MARK: - Refreshable

extension ArticlePresenter: Refreshable {
    
    func refresh() {
        self.viewer?.showLoadingIndicator()
        self.viewer?.update(with: self.article)
        self.viewer?.dismissLoadingIndicator()
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
        self.viewer?.displaySpinner(show: true)
    }
    
    func unblockView() {
        self.viewer?.displaySpinner(show: false)
    }
}
