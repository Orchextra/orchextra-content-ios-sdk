//
//  WebVC.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 26/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import WebKit


class WebVC: UIViewController, WKNavigationDelegate {

    var url: URL!
    
    fileprivate var webview = WKWebView()
    @IBOutlet weak fileprivate var webViewContainer: UIView!
    @IBOutlet weak fileprivate var buttonClose: UIBarButtonItem!
    
    // TOOLBAR
    @IBOutlet weak fileprivate var buttonBack: UIBarButtonItem!
    @IBOutlet weak fileprivate var buttonForward: UIBarButtonItem!
    @IBOutlet weak fileprivate var buttonReload: UIBarButtonItem!
    
    
    // MARK: - Factory Method
    
    class func webview(_ url: URL) -> WebVC? {
        let webVC = UIStoryboard.ocmViewController("WebVC") as? WebVC
        webVC?.url = url
        
        return webVC
    }
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeView()
        
        let request = URLRequest(url: self.url)
        self.webview.load(request)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		OCM.shared.analytics?.trackEvent("NAV_BANNER WEBVIEW")
	}
	
	
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    
    // MARK: - UI Actions
    
    @IBAction func onButtonCancelTap(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBackButtonTap(_ sender: UIBarButtonItem) {
        self.webview.goBack()
        
    }
    
    @IBAction func onForwardButtonTap(_ sender: UIBarButtonItem) {
        self.webview.goForward()
    }
    
    @IBAction func onReloadButtonTap(_ sender: UIBarButtonItem) {
        self.webview.reload()
    }
    
    
    // MARK: - WebView Delegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.updateToolbar()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateToolbar()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.updateToolbar()
    }
  
    
    
    // MARK: - Private Helpers
    
    fileprivate func initializeView() {
        self.webViewContainer.addSubviewWithAutolayout(self.webview)
        self.webview.navigationDelegate = self
        self.updateToolbar()
    }
    
    fileprivate func updateToolbar() {
        self.buttonBack.isEnabled = self.webview.canGoBack
        self.buttonForward.isEnabled = self.webview.canGoForward
    }
    
}
