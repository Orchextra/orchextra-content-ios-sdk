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


class Wireframe: NSObject {
	
	let application: Application
    
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
        webview.url = url
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
        
        guard let articleVC = try? Instantiator<ArticleViewController>().viewController() else {
            LogWarn("Couldn't instantiate ArticleViewController")
            return nil
        }
        
        let presenter = ArticlePresenter(article: article)
        presenter.viewController = articleVC
        articleVC.presenter = presenter
        
        return articleVC
    }
    
    func showMainComponent(with action: Action, viewController: UIViewController) {

        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController else {
            LogWarn("Couldn't instantiate MainContentViewController")
            return
        }
        
        let presenter = MainPresenter(action: action)
        presenter.viewController = mainContentVC
        mainContentVC.presenter = presenter
        
        if let contentList = viewController as? ContentListVC {
            contentList.transition = ZoomTransitioningAnimator()
            mainContentVC.transitioningDelegate = contentList
            mainContentVC.modalPresentationStyle = .custom
            contentList.show(mainContentVC, sender: nil)
        } else {
            viewController.show(mainContentVC, sender: nil)
        }
    }
}

class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
