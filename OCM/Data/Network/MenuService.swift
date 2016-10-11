//
//  MenuService.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 11/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct MenuService {
	
	func getMenus(completion: @escaping (Result<[String: [Section]], Error>) -> Void) {
		let request = Request(
			method: "GET",
			baseUrl: Config.Host,
			endpoint: "/menus",
			verbose: true
		)
		
		request.fetchJson { response in
			switch response.status {
				
			case .success:
				let json = try? response.json()
				Storage.shared.elementsCache = json?["elementsCache"]
				completion(Result.success([:]))
				
			default:
				let error = NSError.UnexpectedError()
				completion(Result.error(error))
			}
		}
	}
	
}
