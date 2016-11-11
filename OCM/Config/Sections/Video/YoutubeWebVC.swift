//
//  YoutubeWebVC.swift
//  OCM
//
//  Created by Carlos Vicente on 8/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import UIKit

class YoutubeWebVC: OrchextraViewController, YoutubeWebView, Instantiable, UIWebViewDelegate {
    
    // MARK: Private properties
    
    private let webView = UIWebView(frame: .zero)
    
    // MARK: Public properties
    
    var presenter: YoutubeWebViewPresenterProtocol?
    
    // MARK: - Instantiable
    
    static func identifier() -> String? {
        return "YoutubeWebVC"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        let height = Int(self.view.frame.height)
        let width = Int(self.view.frame.width)
        self.presenter?.viewIsReady(
            with: height,
            width: width
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTapCloseButton),
            name: Notification.Name(rawValue: "UIWindowDidBecomeHiddenNotification"),
            object: nil
        )
    }
    
    // MARK: - Private Helpers
    
    private func setupView() {
        self.webView.scrollView.isScrollEnabled = false
        self.webView.scrollView.bounces = false
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.isOpaque = false
        self.webView.delegate = self
        self.view.addSubviewWithAutolayout(self.webView)
        
         self.webView.mediaPlaybackRequiresUserAction = false
    }
    
    // MARK: - User interaction
    
    @objc private func userDidTapCloseButton() {
        let _ = self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - YoutubeWebView
    
    func load(with htmlString: String) {
    
        self.webView.loadHTMLString(
            htmlString,
            baseURL: Bundle.main.resourceURL
        )
    }
    
}
