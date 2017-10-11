//
//  WebVCPresenter.swift
//  OCM
//
//  Created by Carlos Vicente on 11/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol PresenterProtocol {
    func viewDidLoad(url: URL)
    func userDidTapReload()
    func userDidTapGoBack()
    func userDidTapGoForward()
    func userDidTapCancel()
    func userDidProvokeRedirection(with url: URL)
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
    
    func userDidProvokeRedirection(with url: URL) {
        self.webInteractor.userDidProvokeRedirection(with: url) { result in
            var message: String = ""
            var passbookError: PassbookError? = nil
			
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
    }
    
}
