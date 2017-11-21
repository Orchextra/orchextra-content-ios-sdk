//
//  RequestExtension.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 3/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
import Orchextra


extension Request {
    
	
	class func OCMRequest(method: String,
	                      endpoint: String,
	                      urlParams: [String: Any]? = nil,
	                      bodyParams: [String: Any]? = nil) -> Request {
		return Request (
			method: method,
			baseUrl: Config.Host,
			endpoint: endpoint,
			headers: self.headers(),
			urlParams: urlParams,
			bodyParams: bodyParams,
			verbose: OCM.shared.logLevel == .debug
		)
	}
    
    // TODO: we don't neeed renewing session if expired
    func fetch(renewingSessionIfExpired renew: Bool, completion: @escaping (Response) -> Void) {
        let orchextra = Orchextra.shared
        orchextra.sendOrxRequest(request: self, completionHandler: completion)
    }
	
	private class func headers() -> [String: String] {
        let acceptLanguage: String = Session.shared.languageCode ?? Locale.currentLanguage()
		
		return [
			"Accept-Language": acceptLanguage,
			"X-ocm-version": Config.SDKVersion
		]
	}
	
}
