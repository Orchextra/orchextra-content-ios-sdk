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


class Wireframe: NSObject, WebVCDismissable {
	
	let application: Application
    var animator: TransitionAnimator?

    init(application: Application) {
        self.application = application
    }
	
	func contentList(from path: String? = nil) -> OrchextraViewController {
		guard let contentListVC = try? Instantiator<ContentListVC>().viewController() else {
			LogWarn("Couldn't instantiate ContentListVC")
			return OrchextraViewController()
		}
		
		contentListVC.presenter = ContentListPresenter(
			view: contentListVC,
			contentListInteractor: ContentListInteractor(
				service: ContentListService(),
				storage: Storage.shared
			),
			defaultContentPath: path
		)
		return contentListVC
	}
	
    func showWebView(url: URL) -> OrchextraViewController? {
        guard let webview = try? Instantiator<WebVC>().viewController() else {
            LogWarn("WebVC not found")
            return nil
        }
        
        let passbookWrapper: PassBookWrapper = PassBookWrapper()
        let webInteractor: WebInteractor = WebInteractor(passbookWrapper: passbookWrapper)
        let webPresenter: WebPresenter = WebPresenter(webInteractor: webInteractor, webView: webview)
        
        webview.url = url
        webview.dismissableDelegate = self
        webview.localStorage = Session.shared.localStorage
        webview.presenter = webPresenter
        return webview
	}
    
    func showYoutubeWebView(videoId: String) -> OrchextraViewController? {
        guard let youtubeWebVC = try? Instantiator<YoutubeWebVC>().viewController() else {
            LogWarn("YoutubeWebVC not found")
            return nil
        }
        
        let youtubeWebInteractor: YoutubeWebInteractor = YoutubeWebInteractor(videoId: videoId)
        let youtubeWebPresenter: YoutubeWebPresenter = YoutubeWebPresenter(
            view: youtubeWebVC,
            interactor: youtubeWebInteractor)
        
        youtubeWebVC.presenter = youtubeWebPresenter
        
        return youtubeWebVC
    }
    
    func showYoutubeVC(videoId: String) -> OrchextraViewController? {
        
        guard let youtubeVC = Bundle.OCMBundle().loadNibNamed("YoutubeVC", owner: self, options: nil)?.first as? YoutubeVC else { return YoutubeVC() }
        youtubeVC.loadVideo(id: videoId)
        return youtubeVC
    }
    
    func showBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.application.presentModal(safariVC)
    }
    
    func show(viewController: UIViewController) {
        self.application.presentModal(viewController)
    }
    
    func showArticle(_ article: Article) -> OrchextraViewController? {
        
        guard let viewController = try? Instantiator<CardsVC>().viewController() else { return nil }
        let wireframe = CardsWireframe()
        let presenter = CardsPresenter(
            view: viewController,
            wireframe: wireframe,
            elements: article.elems
        )
        viewController.presenter = presenter
        
        return viewController
        
        /*guard let articleVC = try? Instantiator<ArticleViewController>().viewController() else {
            LogWarn("Couldn't instantiate ArticleViewController")
            return nil
        }
        
        let presenter = ArticlePresenter(article: article)
        presenter.viewController = articleVC
        articleVC.presenter = presenter
        return articleVC*/
    }
    
    func showMainComponent(with action: Action, viewController: UIViewController) {

        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                LogWarn("Couldn't instantiate MainContentViewController")
                return
        }
        
        let presenter = MainPresenter(action: action)
        presenter.view = mainContentVC
        mainContentVC.presenter = presenter

        if let contentListVC = viewController as? ContentListVC {
            mainContentVC.transitioningDelegate = mainContentVC
            contentListVC.present(mainContentVC, animated: true, completion: nil)
        } else {
            viewController.show(mainContentVC, sender: nil)
        }
    }
    
    func provideMainComponent(with action: Action) -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                LogWarn("Couldn't instantiate MainContentViewController")
                return nil
        }
        
        let presenter = MainPresenter(action: action)
        presenter.view = mainContentVC
        mainContentVC.presenter = presenter
        return mainContentVC
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
