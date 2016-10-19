//
//  Session.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

class Session {
	
	static let shared = Session()
	
	var apiKey: String?
	var apiSecret: String?
	
	var clientToken: String?
	var accessToken: String?
	
}
