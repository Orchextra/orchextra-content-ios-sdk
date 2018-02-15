//
//  WebInteractor.swift
//  OCM
//
//  Created by Carlos Vicente on 11/1/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

public enum PassbookError {
	case error(NSError)
	case unsupportedVersionError(NSError)
}

class WebInteractor {
	let passBookWrapper: PassbookWrapperProtocol
    var passbookResult: PassbookWrapperResult?
    var federated: [String: Any]?
    var resetLocalStorage: Bool?
    var elementUrl: String?
    let sectionInteractor: SectionInteractorProtocol
    let ocm: OCM

    // MARK: - Initializer
    
    init(passbookWrapper: PassbookWrapperProtocol, federated: [String: Any]?, resetLocalStorage: Bool?, elementUrl: String?, sectionInteractor: SectionInteractorProtocol, ocm: OCM) {
        self.passBookWrapper = passbookWrapper
        self.federated = federated
        self.resetLocalStorage = resetLocalStorage
        self.elementUrl = elementUrl
        self.sectionInteractor = sectionInteractor
        self.ocm = ocm
	}
    
    // MARK: - Public methods
    
    func traceSectionLoadForWebview() {
        guard
            let elementUrl = self.elementUrl,
            let section = self.sectionInteractor.sectionForActionWith(identifier: elementUrl)
            else {
                logWarn("Element url or section is nil")
                return
        }
        self.ocm.eventDelegate?.sectionDidLoad(section)
    }
        
    func needResetLocalStorageWebView(completionHandler: @escaping (Bool) -> Void) {
        completionHandler(self.resetLocalStorage ?? false)
    }

    func loadFederated(url: URL, completionHandler: @escaping (URL) -> Void) {
        var urlParse = url
        
        if self.ocm.isLogged {
            if let federatedData = self.federated, federatedData["active"] as? Bool == true {
                self.ocm.federatedAuthenticationDelegate?.federatedAuthentication(federatedData, completion: { params in
                    guard let params = params else {
                        logWarn("Federate params is nil")
                        completionHandler(url)
                        return
                    }
                    var urlFederated = urlParse.absoluteString
                    
                    for (key, value) in params {
                        urlFederated = self.concatURL(url: urlFederated, key: key, value: value)
                    }
                    
                    guard let urlFederatedAuth = URL(string: urlFederated) else {
                        logWarn("urlFederatedAuth is not a valid URL")
                        completionHandler(url)
                        return
                    }
                    urlParse = urlFederatedAuth
                    logInfo("ActionWebview: received urlFederatedAuth: \(url)")
                    completionHandler(urlParse)
                })
            } else {
                logInfo("ActionWebview: open: \(url)")
                completionHandler(urlParse)
            }
        } else {
            logInfo("ActionWebview: open: \(url)")
            completionHandler(url)
        }
    }
	
    func downloadPassbook(with url: URL, completionHandler: @escaping (PassbookWrapperResult) -> Void) {
        let urlString = url.absoluteString
        self.passBookWrapper.addPassbook(from: urlString) { result in
            switch result {
            case .success:
                completionHandler(.success)
                
            case .unsupportedVersionError(let error):
                completionHandler(.unsupportedVersionError(error))
                
            case .error(let error):
                completionHandler(.error(error))
            }
            
            self.passbookResult = result
        }
    }
    
    // MARK: - Private methods
    
    private func concatURL(url: String, key: String, value: Any) -> String {
        guard let valueURL = value as? String else {
            logWarn("Value URL is not a String")
            return url
        }
        
        var urlResult = url
        if url.contains("?") {
            urlResult = "\(url)&\(key)=\(valueURL)"
        } else {
            urlResult = "\(url)?\(key)=\(valueURL)"
        }
        return urlResult
    }
}
