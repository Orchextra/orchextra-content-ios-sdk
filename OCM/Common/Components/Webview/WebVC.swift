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

    var url: NSURL!
    
    private var webview = WKWebView()
    @IBOutlet weak private var webViewContainer: UIView!
    @IBOutlet weak private var buttonClose: UIBarButtonItem!
    
    // TOOLBAR
    @IBOutlet weak private var buttonBack: UIBarButtonItem!
    @IBOutlet weak private var buttonForward: UIBarButtonItem!
    @IBOutlet weak private var buttonReload: UIBarButtonItem!
    
    
    // MARK: - Factory Method
    
    class func webview(url: NSURL) -> WebVC? {
        let webVC = UIStoryboard.ocmViewController("WebVC") as? WebVC
        webVC?.url = url
        
        return webVC
    }
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeView()
        
        let request = NSURLRequest(URL: self.url)
        self.webview.loadRequest(request)
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		OCM.shared.analytics?.trackEvent("NAV_BANNER WEBVIEW")
	}
	
	
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    
    // MARK: - UI Actions
    
    @IBAction func onButtonCancelTap(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onBackButtonTap(sender: UIBarButtonItem) {
        self.webview.goBack()
        
    }
    
    @IBAction func onForwardButtonTap(sender: UIBarButtonItem) {
        self.webview.goForward()
    }
    
    @IBAction func onReloadButtonTap(sender: UIBarButtonItem) {
        self.webview.reload()
    }
    
    
    // MARK: - WebView Delegate
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.updateToolbar()
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.updateToolbar()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.updateToolbar()
    }
  
    
    
    // MARK: - Private Helpers
    
    private func initializeView() {
        self.webViewContainer.addSubviewWithAutolayout(self.webview)
        self.webview.navigationDelegate = self
        self.updateToolbar()
    }
    
    private func updateToolbar() {
        self.buttonBack.enabled = self.webview.canGoBack
        self.buttonForward.enabled = self.webview.canGoForward
    }
    
}
