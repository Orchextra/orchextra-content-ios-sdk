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
    
    func showArticle(_ article: Article) {
        
        let storyboard = UIStoryboard.init(name: "Article", bundle: Bundle.OCM())
        guard let articleVC = storyboard.instantiateInitialViewController() else {return}
        
        self.application.presentModal(articleVC)
        
    }
	
}



class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}
