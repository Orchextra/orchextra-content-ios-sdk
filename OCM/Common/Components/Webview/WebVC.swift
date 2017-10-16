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

protocol WebView: class {
	func showPassbook(error: PassbookError)
	func displayInformation(url: URL)
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
	var localStorage: [AnyHashable: Any]?
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
    
    static var identifier =  "WebVC"
	
	// MARK: - View LifeCycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.presenter?.viewDidLoad(url: self.url)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    deinit {
        // HOTFIX: Avoid iOS 9 crash of over-releasing weak references
        self.webview.scrollView.delegate = nil
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url else { return }
        if navigationResponse.response.mimeType == "application/pdf" {
            decisionHandler(.cancel)
            UIApplication.shared.openURL(url)
        } else if navigationResponse.response.mimeType == "application/vnd.apple.pkpass" {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
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
    
    fileprivate func loadRequest(url: URL) {
        var request =  URLRequest(url: url,
                                  cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData,
                                  timeoutInterval: 10.0
        )
        request.addValue(Locale.currentLanguage(), forHTTPHeaderField: "Accept-Language")
		self.webview.load(request)
	}
    
    fileprivate func process(result: Any?) {
        if result != nil {
            logInfo("RESULT: \(String(describing: result))")
        }
    }
    
    fileprivate func process(error: Error?) {
        if let error = error {
            logError(error as NSError)
        }
    }
	
	// MARK: - Public Local Storage
	
	public func updateLocalStorage() {
		guard let localStorage = self.localStorage else {
            let entryLocalStorage = "localStorage.clear();"
            self.webview.evaluateJavaScript(entryLocalStorage, completionHandler: { result, error in
                self.process(result: result)
                self.process(error: error)
            })
            
            return
        }
        
		if self.webViewNeedsReload {
            for (key, value) in localStorage {
                let entryLocalStorage = "localStorage.setItem('\(key)', '\(value)');"
                self.webview.evaluateJavaScript(entryLocalStorage, completionHandler: { result, error in
                    self.process(result: result)
                    self.process(error: error)
                })
            }
			self.webViewNeedsReload = false
			self.webview.reload()
		}
	}
	
	// MARK: WebView protocol methods
	func displayInformation(url: URL) {
		self.initializeView()
		self.loadRequest(url: url)
	}
	
	func showPassbook(error: PassbookError) {
        var message: String = ""
        switch error {
        case .error:
            message = kLocaleErrorUnexpected
        case .unsupportedVersionError:
            message = kLocaleErrorPassbookUnsupportedVersion
        }
        
        let alert = Alert(title: kLocaleAppName.uppercased(), message: message)
        alert.addDefaultButton(kLocaleButtonOk, usingAction: nil)
        alert.show()
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
