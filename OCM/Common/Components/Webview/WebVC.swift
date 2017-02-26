//
//  WebVC.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 26/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import WebKit
import GIGLibrary

protocol WebVCDelegate: class {
	func webViewDidScroll(_ scrollView: UIScrollView)
}

protocol WebVCDismissable: class {
	func dismiss(webVC: WebVC)
}

protocol WebView {
	func showPassbook(error: PassbookError)
	func displayInformation()
	func reload()
	func goBack()
	func goForward()
	func dismiss()
}

class WebVC: OrchextraViewController, Instantiable, WebView, WKNavigationDelegate, UIScrollViewDelegate {
	var url: URL!
	weak var delegate: WebVCDelegate?
	weak var dismissableDelegate: WebVCDismissable?
	var webViewNeedsReload = true
	var localStorage: [AnyHashable : Any]?
	var presenter: WebPresenter?
	
	fileprivate var webview = WKWebView()
	@IBOutlet weak fileprivate var webViewContainer: UIView!
	@IBOutlet weak var controlBar: UIToolbar!
	@IBOutlet weak fileprivate var buttonClose: UIBarButtonItem!
	
	// TOOLBAR
	@IBOutlet weak fileprivate var buttonBack: UIBarButtonItem!
	@IBOutlet weak fileprivate var buttonForward: UIBarButtonItem!
	@IBOutlet weak fileprivate var buttonReload: UIBarButtonItem!
	
	
	// MARK: - Factory Method
	
	static func identifier() -> String? {
		return "WebVC"
	}
	
	// MARK: - View LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.presenter?.viewDidLoad()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	
	// MARK: - UI Actions
	
	@IBAction func onButtonCancelTap(_ sender: UIBarButtonItem) {
		self.presenter?.userDidTapCancel()
	}
	
	@IBAction func onBackButtonTap(_ sender: UIBarButtonItem) {
		self.presenter?.userDidTapGoBack()
	}
	
	@IBAction func onForwardButtonTap(_ sender: UIBarButtonItem) {
		self.presenter?.userDidTapGoForward()
	}
	
	@IBAction func onReloadButtonTap(_ sender: UIBarButtonItem) {
		self.presenter?.userDidTapReload()
	}
	
	
	// MARK: - WebView Delegate
	
	func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		guard let url = webview.url else { return }
		self.presenter?.userDidProvokeRedirection(with: url)
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		
		self.updateLocalStorage ()
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	// MARK: - UISCrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.delegate?.webViewDidScroll(scrollView)
	}
	
	// MARK: - Private Helpers
	
	fileprivate func initializeView() {
		self.webview.scrollView.delegate = self
		self.webview.navigationDelegate = self
		
		self.webViewContainer = self.addConstraints(view: self.webViewContainer)
		self.webview.scrollView.bounces = true
		self.webViewContainer.addSubviewWithAutolayout(self.webview)
	}
	
	fileprivate func updateToolbar() {
		self.buttonBack.isEnabled = self.webview.canGoBack
		self.buttonForward.isEnabled = self.webview.canGoForward
	}
	
	fileprivate func addConstraints(view: UIView) -> UIView {
		view.translatesAutoresizingMaskIntoConstraints = false
		
		let Hconstraint = NSLayoutConstraint(
			item: view,
			attribute: NSLayoutAttribute.width,
			relatedBy: NSLayoutRelation.equal,
			toItem: nil,
			attribute: NSLayoutAttribute.notAnAttribute,
			multiplier: 1.0,
			constant: UIScreen.main.bounds.width
		)
		
		let Vconstraint = NSLayoutConstraint(
			item: view,
			attribute: NSLayoutAttribute.height,
			relatedBy: NSLayoutRelation.equal,
			toItem: nil,
			attribute: NSLayoutAttribute.notAnAttribute,
			multiplier: 1.0,
			constant: self.view.frame.height
		)
		
		view.addConstraints([Hconstraint, Vconstraint])
		return view
	}
	
	fileprivate func loadRequest() {
		var request = URLRequest(url: self.url)
		request.addValue(Locale.currentLanguage(), forHTTPHeaderField: "Accept-Language")
		self.webview.load(request)
	}
	
	// MARK: - Public Local Storage
	
	public func updateLocalStorage() {
		guard let localStorage = self.localStorage else { return }
		
		for (key, value) in localStorage {
			let entryLocalStorage = "localStorage.setItem(\(key), \(value));"
			self.webview.evaluateJavaScript(entryLocalStorage, completionHandler: nil)
		}
		
		if self.webViewNeedsReload {
			self.webViewNeedsReload = false
			self.webview.reload()
		}
	}
	
	
	// MARK: WebView protocol methods
	func displayInformation() {
		self.initializeView()
		self.loadRequest()
	}
	
	func showPassbook(error: PassbookError) {
		OCM.shared.delegate?.showPassbook(error: error)
	}
	
	func reload() {
		self.webview.reload()
	}
	
	func goBack() {
		self.webview.goBack()
	}
	
	func goForward() {
		self.webview.goForward()
	}
	
	func dismiss() {
		self.dismissableDelegate?.dismiss(webVC: self)
	}
	
}
