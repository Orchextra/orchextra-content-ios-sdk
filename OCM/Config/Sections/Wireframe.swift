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


struct Wireframe {
	
	let application: Application
	
	func contentList(from path: String) -> UIViewController {
		guard let contentListVC = UIStoryboard.ocmInitialVC() as? ContentListVC else {
			LogWarn("Couldn't instantiate ContentListVC")
			return UIViewController()
		}
		
		contentListVC.presenter = ContentListPresenter(
			path: path,
			view: contentListVC,
			contentListInteractor: ContentListInteractor(
				service: ContentListService(),
				storage: Storage.shared
			)
		)
		
		return contentListVC
	}
	
	func showWebView(_ url: URL) {
		// Next commented lines are for browser
		//			let svc = SFSafariViewController(URL: url)
		//			self.application.presentModal(svc)
		
		guard let webview = WebVC.webview(url) else {
			return LogWarn("WebVC not found")
		}
		
		let navBar = OCMNavigationController(rootViewController: webview)
		self.application.presentModal(navBar)
	}
    
    func showArticle(_ article: Article, viewController: UIViewController) {
        
        let storyboard = UIStoryboard.init(name: "Article", bundle: Bundle.OCM())
        
        guard let articleVC = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController else {
            LogWarn("Couldn't instantiate ArticleViewController")
            return
        }
        
        let presenter = ArticlePresenter(article: article)
        presenter.viewController = articleVC
        articleVC.presenter = presenter
        viewController.show(articleVC, sender: nil)
    }
    
    func showMainComponent(with article: Article, action: Action, viewController: UIViewController) {

        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCM())
        
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController else {
            LogWarn("Couldn't instantiate MainContentViewController")
            return
        }
        
        let presenter = MainPresenter(preview: article.preview, action: action)
        presenter.viewController = mainContentVC
        mainContentVC.presenter = presenter
        viewController.show(mainContentVC, sender: nil)
    }
    
    func showArticle(_ article: Article) -> ArticleViewController? {
        let storyboard = UIStoryboard.init(name: "Article", bundle: Bundle.OCM())
        
        guard let articleVC = storyboard.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController else {
            LogWarn("Couldn't instantiate ArticleViewController")
            return nil
        }
        
        let presenter = ArticlePresenter(article: article)
        presenter.viewController = articleVC
        articleVC.presenter = presenter
        return articleVC
    }
}

class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
