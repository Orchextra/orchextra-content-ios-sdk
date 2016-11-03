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
import Orchextra


class ViewController: UIViewController, OCMDelegate {

	let ocm = OCM.shared
	let orchextra: Orchextra = Orchextra.sharedInstance()
	var menu: [Section]?
	@IBOutlet weak var tableView: UITableView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		Orchextra.logLevel(.all)
        
        
		self.ocm.delegate = self
		self.ocm.host = "https://cm.q.orchextra.io"
		self.ocm.countryCode = "ES"
		self.ocm.appVersion = "IOS_2.2"
		self.ocm.logLevel = .debug
        self.ocm.loadingView = LoadingView()
        self.ocm.noContentView = NoContentView()
        
        self.ocm.placeholder = UIImage(named: "placeholder")
		self.ocm.palette = Palette(navigationBarColor: UIColor.red)
		
		self.orchextra.setApiKey("0a702d5157f7c3424f39bcdf8312a98d7d8fdde4", apiSecret: "ce9592f7e841b4fc067d76467457544bdd95f5e7") { success, error in
			LogInfo("setApiKey return")
			if success {
				self.ocm.menus() { menus in
					if let menu: Menu = menus.first {
						self.menu = menu.sections
						self.tableView.reloadData()
					}
				}
			} else { LogError(error as NSError?) }
		}
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
		
		if let view = section?.openAction() {
			self.navigationController?.pushViewController(view, animated: true)
		}
	}
}

class LoadingView: StatusView {
    func instantiate() -> UIView {
        let loadingView = UIView(frame: CGRect.zero)
        loadingView.addSubviewWithAutolayout(UIImageView(image: #imageLiteral(resourceName: "loading")))
        loadingView.backgroundColor = .blue
        return loadingView
    }
}

class NoContentView: StatusView {
    func instantiate() -> UIView {
        let loadingView = UIView(frame: CGRect.zero)
        loadingView.addSubviewWithAutolayout(UIImageView(image: #imageLiteral(resourceName: "DISCOVER MORE")))
        loadingView.backgroundColor = .gray
        return loadingView
    }
}
