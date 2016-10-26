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
		guard let contentListVC = try? Instantiator<ContentListVC>().viewController() else {
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
		
		guard let webview = try? Instantiator<WebVC>().viewController() else {
			return LogWarn("WebVC not found")
		}
		
		webview.url = url
		let navBar = OCMNavigationController(rootViewController: webview)
		self.application.presentModal(navBar)
	}
    
    func showArticle(_ article: Article) -> UIViewController? {
        
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
        viewController.show(mainContentVC, sender: nil)
    }
}

class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
