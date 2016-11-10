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
		self.ocm.host = "https://cm-demo.q.orchextra.io" //"https://cm.q.orchextra.io"
		self.ocm.countryCode = "ES"
		self.ocm.appVersion = "IOS_2.2"
		self.ocm.logLevel = .debug
        self.ocm.loadingView = LoadingView()
        self.ocm.noContentView = NoContentView()
        self.ocm.errorViewInstantiator = MyErrorView.self
        self.ocm.loginState = "anonymous"
        
        self.ocm.placeholder = UIImage(named: "placeholder")
		self.ocm.palette = Palette(navigationBarColor: UIColor.red)
		
		self.orchextra.setApiKey("b65910721cdc73000b9c528e660ff050b553c2db", apiSecret: "e460fa2f55b6d18860de8300a4b96493c5909019") { success, error in
			LogInfo("setApiKey return")
			if success {
				self.ocm.menus() { (succeed, menus, error) in
                    if succeed {
                        if let menu: Menu = menus.first {
                            self.menu = menu.sections
                            self.tableView.reloadData()
                        }
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
    
    func requiredUserAuthentication() {
        print("User authentication needed it.")
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

class MyErrorView: UIView, ErrorView {
    
    var retryBlock: (() -> Void)?
    public func view() -> UIView {
        return self
    }

    public func set(retryBlock: @escaping () -> Void) {
        self.retryBlock = retryBlock
    }

    public func set(errorDescription: String) {
        
    }

        
    static func instantiate() -> ErrorView {

        let errorView = MyErrorView(frame: CGRect.zero)
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.addTarget(errorView, action: #selector(didTapRetry), for: .touchUpInside)
        errorView.addSubviewWithAutolayout(button)
        errorView.backgroundColor = .gray
        return errorView
    }
    
    func didTapRetry() {
        retryBlock?()
    }
}
