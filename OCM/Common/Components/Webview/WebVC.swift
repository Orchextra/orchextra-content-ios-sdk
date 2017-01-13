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

protocol WebVCDelegate {
    func webViewDidScroll(_ scrollView: UIScrollView)
}

class WebVC: OrchextraViewController, Instantiable, WKNavigationDelegate, UIScrollViewDelegate {

    var url: URL!
    var delegate: WebVCDelegate?
    
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
        self.initializeView()
        
        var request = URLRequest(url: self.url)
		request.addValue(Locale.currentLanguage(), forHTTPHeaderField: "Accept-Language")
        self.webview.load(request)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
    override var preferredStatusBarStyle: UIStatusBarStyle {
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
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    func addConstraints(view: UIView) -> UIView {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Hconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        let Vconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.height,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: self.view.frame.height)
        
        view.addConstraints([Hconstraint, Vconstraint])
        return view
    }
    
}
