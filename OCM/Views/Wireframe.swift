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
	
	func widgetList() -> UIViewController {
		let widgetListVC = UIStoryboard.ocmInitialVC() as! WidgetListVC
		
		widgetListVC.presenter = WidgetListPresenter(view: widgetListVC)
		
		return widgetListVC
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
	
}



class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
}
