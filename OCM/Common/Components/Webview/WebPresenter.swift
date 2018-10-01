//
//  WebVCPresenter.swift
//  OCM
//
//  Created by Carlos Vicente on 11/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

protocol PresenterProtocol {
    func viewDidLoad(url: URL)
    func userDidTapReload()
    func userDidTapGoBack()
    func userDidTapGoForward()
    func userDidTapCancel()
}

class WebPresenter: PresenterProtocol {
    let webInteractor: WebInteractor
    weak var webView: WebView?
    
    init(webInteractor: WebInteractor, webView: WebView) {
        self.webInteractor = webInteractor
        self.webView = webView
    }
    
    // MARK: Presenter protocol
    func viewDidLoad(url: URL) {
        self.webInteractor.traceSectionLoadForWebview()        
        self.webInteractor.loadFederated(url: url) { url in
            self.webView?.displayInformation(url: url)
        }        
    }
    
    func userDidTapReload() {
        self.webView?.reload()
    }
    
    func userDidTapGoBack() {
        self.webView?.goBack()
    }
    
    func userDidTapGoForward() {
        self.webView?.goForward()
    }
    
    func userDidTapCancel() {
        self.webView?.dismiss()
    }
    
    func allowNavigation(for url: URL, mimeType: String, decisionHandler: @escaping (Bool) -> Void) {
        if mimeType == "application/pdf" {
            UIApplication.shared.openURL(url)
            decisionHandler(false)
        } else if mimeType == "application/vnd.apple.pkpass" {
            self.webInteractor.downloadPassbook(with: url) { result in
                var message: String = ""
                var passbookError: PassbookError?
                switch result {
                case .success:
                    message = "Passbook: downloaded successfully"
                    logInfo(message)
                case .unsupportedVersionError(let error):
                    message = "Passbook: Unsupported version ---\(error.localizedDescription)"
                    logInfo(message)
                    passbookError = PassbookError.unsupportedVersionError(error)
                case .error(let error):
                    message = "Passbook: \(error.localizedDescription)"
                    logInfo(message)
                    logError(error)
                    passbookError = PassbookError.error(error)
                }
                if let error = passbookError {
                    self.webView?.showPassbook(error: error)
                }
            }
            decisionHandler(false)
        } else if mimeType == "image/jpeg" || mimeType == "image/png" {
            UIApplication.shared.openURL(url)
            decisionHandler(false)
        } else {
            decisionHandler(true)
        }
    }
}
