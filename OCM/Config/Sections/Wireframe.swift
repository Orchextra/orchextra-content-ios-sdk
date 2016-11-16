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
			path: path
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
        viewController.show(mainContentVC, sender: nil)
    }
}

class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
