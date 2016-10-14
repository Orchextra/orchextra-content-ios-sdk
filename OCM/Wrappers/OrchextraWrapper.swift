//
//  OrchextraWrapper.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//
import Foundation
import GIGLibrary
import Orchextra


typealias OrchextraResult = Result<(clientToken: String, accessToken: String), Error>

struct OrchextraWrapper {
	
	let config = ORCSettingsDataManager()
	
	func loadApiKey() -> String? {
		self.checkOrchextra()
		
		//TODO:
		LogWarn("TODO")
		
		return "hardcoded_api_key"
	}
	
	func loadApiSecret() -> String? {
		self.checkOrchextra()
		
		//TODO:
		LogWarn("TODO")
		
		return "hardcoded_api_secret"
	}
	
	func startWith(apikey: String, apiSecret: String, completion: (OrchextraResult) -> Void) {
		//TODO:
		LogWarn("TODO")
		
		completion(Result.success(clientToken: "hardcoded_client_token", accessToken: "hardcoded_access_token"))
	}
	
	
	private func checkOrchextra() {
		if !self.config.isOrchextraRunning() {
			LogInfo("Orchextra is not running! You must set the api key and api secret first.")
		}
	}
}
