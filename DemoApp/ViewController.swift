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
	var menu: [Section]?
	@IBOutlet weak var tableView: UITableView!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.ocm.delegate = self
		self.ocm.host = "https://cm.s.orchextra.io"
		self.ocm.countryCode = "ES"
		self.ocm.appVersion = "IOS_2.2"
		self.ocm.logLevel = .debug
		self.ocm.placeholder = UIImage(named: "placeholder")
		self.ocm.noContentImage = UIImage(named: "no_content")
		self.ocm.palette = Palette(navigationBarColor: UIColor.red)
		
		self.menu = self.ocm.sectionList().first?.value
	}
	
	
	@IBAction func onButtonShowContentListTap(_ sender: AnyObject) {
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

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.menu?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
		
		let section = self.menu?[indexPath.row]
		
		cell?.textLabel?.text = section?.name
		
		return cell!
	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let section = self.menu?[indexPath.row]
		
		let view = section?.openAction()
		self.navigationController?.pushViewController(view!, animated: true)
	}
}


