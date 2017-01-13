//
//  WebVCPresenter.swift
//  OCM
//
//  Created by Carlos Vicente on 11/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol PresenterProtocol {
    func viewDidLoad()
    func userDidTapReload()
    func userDidTapGoBack()
    func userDidTapGoForward()
    func userDidTapCancel()
    func userDidProvokeRedirection(with url: URL)
}

struct WebPresenter: PresenterProtocol {
    let webInteractor: WebInteractor
    let webView: WebView
    
    // MARK: Presenter protocol
    func viewDidLoad() {
        self.webView.displayInformation()
    }
    
    func userDidTapReload() {
        self.webView.reload()
    }
    
    func userDidTapGoBack() {
        self.webView.goBack()
    }
    
    func userDidTapGoForward() {
        self.webView.goForward()
    }
    
    func userDidTapCancel() {
        self.webView.dismiss()
    }
    
    func userDidProvokeRedirection(with url: URL) {
        self.webInteractor.userDidProvokeRedirection(with: url) { result in
            var message: String = ""
            switch result {
            case .success:
                message = "Passbook: downloaded successfully"
                LogInfo(message)
                
            case .unsupportedVersionError(let error):
                message = "Passbook: Unsupported version ---\(error.localizedDescription)"
                LogInfo(message)
                self.show(message: message)
                
            case .error(let error):
                message = "Passbook: \(error.localizedDescription)"
                LogInfo(message)
                LogError(error)
                self.show(message: message)
            }
        }
    }
    
    // MARK: Private Helpers
    func show(message: String) {
        if message.characters.count > 0 {
            self.webView.show(message: message)
        }
    }
}
