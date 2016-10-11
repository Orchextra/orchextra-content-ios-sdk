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
		
		let ocm = OCM.shared
		ocm.delegate = self
		ocm.host = "https://cm.s.orchextra.io"
		ocm.countryCode = "ES"
		ocm.appVersion = "IOS_2.2"
		ocm.logLevel = .debug
		ocm.placeholder = UIImage(named: "placeholder")
		ocm.noContentImage = UIImage(named: "no_content")
		ocm.palette = Palette(navigationBarColor: UIColor.red)
	}
	
	
	
	@IBAction func onButtonSimulatePushTap(_ sender: AnyObject) {
		let notification: [AnyHashable : Any] = [
			"action": self.textPush.text
		]
		
		self.ocm.notificationReceived(notification)
	}
	
	
	@IBAction func onButtonShowContentListTap(_ sender: AnyObject) {
//		let menu = self.ocm.sectionList()
//		let firstSection = menu.first?.value.first
//		
//		let contentList = self.ocm.contentList(from: "orchextra://content/home")
//		self.navigation = UINavigationController(rootViewController: contentList)
//		self.addClose(self.navigation)
//		self.show(self.navigation, sender: self)
//		
//		self.show(contentList, sender: self)
	}
	
	
	@IBAction func onButtonRunContentTap(_ sender: AnyObject) {
		self.ocm.openContent("57597f68998f475e788b4578")
	}
	
	
	// MARK - OCMDelegate
	
	func openCoupons() {
		print("OPEN COUPONS!!")
	}
	
	func openCoupon(with id: String) {
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

