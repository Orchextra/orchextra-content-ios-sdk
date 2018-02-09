//
//  Wireframe.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
import SafariServices

protocol OCMWireframe {
    func loadContentList(from path: String?) -> OrchextraViewController
    func loadWebView(with action: ActionWebview) -> OrchextraViewController?
    func loadYoutubeVC(with videoId: String) -> OrchextraViewController?
    func loadVideoPlayerVC(with video: Video) -> OrchextraViewController?
    func loadCards(with cards: [Card]) -> OrchextraViewController?
    func loadArticle(with article: Article, elementUrl: String?) -> OrchextraViewController?
    func loadMainComponent(with action: Action) -> UIViewController?
    
    func showBrowser(url: URL)
    func show(viewController: UIViewController)
    func showMainComponent(with action: Action, viewController: UIViewController)
}

class Wireframe: OCMWireframe, WebVCDismissable {
    
    // MARK: - Attributes
	
	let application: Application

    // MARK: - Init methods
    
    init(application: Application) {
        self.application = application
    }
    
    // MARK: - Loading methods
	
    func loadContentList(from path: String? = nil) -> OrchextraViewController {
		guard let contentListVC = try? ContentListVC.instantiateFromStoryboard() else {
			logWarn("Couldn't instantiate ContentListVC")
			return OrchextraViewController()
		}
        let contentListInteractor = ContentListInteractor(
            contentPath: path,
            sectionInteractor: SectionInteractor(
                contentDataManager: .sharedDataManager
            ),
            actionInteractor: ActionInteractor(
                contentDataManager: .sharedDataManager,
                ocm: OCM.shared,
                actionScheduleManager: ActionScheduleManager.shared
            ),
            contentCoodinator: ContentCoordinator.shared,
            contentDataManager: .sharedDataManager,
            ocm: OCM.shared
        )
		contentListVC.presenter = ContentListPresenter(
			view: contentListVC,
			contentListInteractor: contentListInteractor,
            ocm: OCM.shared,
            actionScheduleManager: ActionScheduleManager.shared
		)
		return contentListVC
	}
	
    func loadWebView(with action: ActionWebview) -> OrchextraViewController? {
        guard let webview = try? WebVC.instantiateFromStoryboard() else {
            logWarn("WebVC not found or action doesn't a ActionWebview")
            return nil
        }
        
        let passbookWrapper: PassBookWrapper = PassBookWrapper()
        let webInteractor: WebInteractor = WebInteractor(
            passbookWrapper: passbookWrapper,
            federated: action.federated,
            resetLocalStorage: action.resetLocalStorage,
            elementUrl: action.elementUrl,
            sectionInteractor: SectionInteractor(
                contentDataManager: .sharedDataManager
            ),
            ocm: OCM.shared
        )
        action.updateLocalStorage()
        
        let webPresenter: WebPresenter = WebPresenter(webInteractor: webInteractor, webView: webview)
        
        webview.url = action.url
        webview.dismissableDelegate = self
        webview.localStorage = Session.shared.localStorage
        webview.presenter = webPresenter
        return webview
	}

    func loadYoutubeVC(with videoId: String) -> OrchextraViewController? {
        guard let youtubeVC = try? YoutubeVC.instantiateFromStoryboard() else { return nil }
        youtubeVC.loadVideo(identifier: videoId)
        return youtubeVC
    }
    
    func loadVideoPlayerVC(with video: Video) -> OrchextraViewController? {
        let viewController = VideoPlayerVC()
        let wireframe = VideoPlayerWireframe()
        let vimeoWrapper = VimeoDataManager.sharedDataManager
        let videoInteractor = VideoInteractor(
            vimeoWrapper: vimeoWrapper
        )
        let presenter = VideoPlayerPresenter(
            view: viewController,
            wireframe: wireframe,
            video: video,
            videoInteractor: videoInteractor
        )
        vimeoWrapper.output = videoInteractor
        viewController.presenter = presenter
        return viewController
    }
    
    func loadCards(with cards: [Card]) -> OrchextraViewController? {
        guard let viewController = try? CardsVC.instantiateFromStoryboard() else { return nil }
        let presenter = CardsPresenter(
            view: viewController,
            cards: cards
        )
        viewController.presenter = presenter
        return viewController
    }
    
    func loadArticle(with article: Article, elementUrl: String?) -> OrchextraViewController? {
        guard let articleVC = try? ArticleViewController.instantiateFromStoryboard() else {
            logWarn("Couldn't instantiate ArticleViewController")
            return nil
        }
        let actionInteractor = ActionInteractor(
            contentDataManager: .sharedDataManager,
            ocm: OCM.shared,
            actionScheduleManager: ActionScheduleManager.shared
        )
        let articleInteractor = ArticleInteractor(
            elementUrl: elementUrl,
            sectionInteractor: SectionInteractor(
                contentDataManager: .sharedDataManager
            ),
            actionInteractor: actionInteractor,
            ocm: OCM.shared
        )
        let presenter = ArticlePresenter(
            article: article,
            view: articleVC,
            actionInteractor: actionInteractor,
            articleInteractor: articleInteractor,
            ocm: OCM.shared,
            actionScheduleManager: ActionScheduleManager.shared,
            refreshManager: RefreshManager.shared,
            reachability: ReachabilityWrapper.shared
        )
        articleInteractor.output = presenter
        articleInteractor.actionOutput = presenter
        let videoInteractor = VideoInteractor(
            vimeoWrapper: VimeoDataManager.sharedDataManager
        )
        videoInteractor.output = presenter
        presenter.videoInteractor = videoInteractor
        articleVC.presenter = presenter
        return articleVC
    }
    
    func loadMainComponent(with action: Action) -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                logWarn("Couldn't instantiate MainContentViewController")
                return nil
        }
        
        let presenter = MainPresenter(action: action, ocm: OCM.shared)
        presenter.view = mainContentVC
        mainContentVC.presenter = presenter
        return mainContentVC
    }
    
    // MARK: - Showing methods
    
    func showMainComponent(with action: Action, viewController: UIViewController) {

        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                logWarn("Couldn't instantiate MainContentViewController")
                return
        }
        
        let presenter = MainPresenter(action: action, ocm: OCM.shared)
        presenter.view = mainContentVC
        mainContentVC.presenter = presenter

        if let contentListVC = viewController as? ContentListVC {
            contentListVC.transitionManager = ContentListTransitionManager(contentListVC: contentListVC, mainContentVC: mainContentVC)
            contentListVC.present(mainContentVC, animated: true, completion: nil)
        } else {
            viewController.show(mainContentVC, sender: nil)
        }
    }
    
    func showBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.application.presentModal(safariVC)
    }
    
    func show(viewController: UIViewController) {
        self.application.presentModal(viewController)
    }
    
    // MARK: WebVCDismissable methods
    
    func dismiss(webVC: WebVC) {
      _ = webVC.navigationController?.popViewController(animated: true)
    }
}

class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension SFSafariViewController {
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
