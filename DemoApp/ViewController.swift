//
//  ViewController.swift
//  DemoApp
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import OCMSDK
import GIGLibrary

class ViewController: UIViewController, OCMDelegate {

	let ocm = OCM.shared
	
	fileprivate var navigation: UINavigationController!
	@IBOutlet weak var textPush: UITextView!
	@IBOutlet var buttons: [UIButton]!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		for button in self.buttons {
			button.isHidden = true
		}
		
		let ocm = OCM.shared
		ocm.delegate = self
		ocm.host = "https://api-discover-mcd.s.gigigoapps.com"
		ocm.countryCode = "BR"
		ocm.appVersion = "IOS_2.2"
		ocm.logLevel = .debug
		ocm.placeholder = UIImage(named: "placeholder")
		ocm.noContentImage = UIImage(named: "no_content")
		ocm.palette = OCMPalette(navigationBarColor: UIColor.red)
		
		Request(
			method: "POST",
			baseUrl: "https://api-discover-mcd.s.gigigoapps.com",
			endpoint: "/security/login",
			headers: [
				"X-app-version": "IOS_2.2",
				"X-app-country": "BR",
				"X-app-language": "pt"
			],
			bodyParams: [
				"grantType": "password",
				"email" : "alejandro.jimenez@gigigo.com",
				"password" : "hispalis1",
				"deviceId" : "wefr23f2wr4fg42g"
			]
			)
			.fetchJson { _ in
				for button in self.buttons {
					button.isHidden = false
				}
		}
		
	}
	
	
	
	@IBAction func onButtonSimulatePushTap(_ sender: AnyObject) {
		let notification: [AnyHashable : Any] = [
			"action": self.textPush.text
		]
		
		self.ocm.notificationReceived(notification)
	}
	
	
	@IBAction func onButtonShowWidgetListTap(_ sender: AnyObject) {
		let widgetList = self.ocm.widgetList()
		self.navigation = UINavigationController(rootViewController: widgetList)
		self.addClose(self.navigation)
		self.show(self.navigation, sender: self)
		
		self.show(widgetList, sender: self)
	}
	
	
	@IBAction func onButtonRunWidgetTap(_ sender: AnyObject) {
		self.ocm.openWidget("57597f68998f475e788b4578")
	}
	
	
	// MARK - OCMDelegate
	
	func openCoupons() {
		print("OPEN COUPONS!!")
	}
	
	func openCoupon(_ id: String) {
		print("OPEN COUPON \(id)")
	}
	
	func sessionExpired() {
		print("Session expired")
	}
	
	func customScheme(_ url: URLComponents) {
		print("CUSTOM SCHEME: \(url)")
		UIApplication.shared.openURL(url.url!)
	}
	
	
	// MARK: - Private Helpers
	
	fileprivate func addClose(_ nav: UINavigationController) {
		let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
		nav.navigationBar.tintColor = UIColor.white
		nav.navigationBar.topItem?.leftBarButtonItems = [closeButton]
	}
	
	@objc fileprivate func close() {
		self.navigation.dismiss(animated: true, completion: nil)
	}

}

