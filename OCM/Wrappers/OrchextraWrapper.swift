//
//  OrchextraAdapter.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


typealias OrchextraResult = Result<(clientToken: String, accessToken: String), Error>

struct OrchextraWrapper {
	
	func loadApiKey() -> String? {
		//TODO:
		LogWarn("TODO")
		
		return "hardcoded_api_key"
	}
	
	func loadApiSecret() -> String? {
		//TODO:
		LogWarn("TODO")
		
		return "hardcoded_api_secret"
	}
	
	func startWith(apikey: String, apiSecret: String, completion: (OrchextraResult) -> Void) {
		//TODO:
		LogWarn("TODO")
		
		completion(Result.success(clientToken: "hardcoded_client_token", accessToken: "hardcoded_access_token"))
	}
	
}
