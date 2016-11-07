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
	
	func getMenus(completion: @escaping (Result<[Menu], Error>) -> Void) {
        let request = Request.OCMRequest(
			method: "GET",
			endpoint: "/menus"
		)
		
		request.fetch { response in
			switch response.status {
				
			case .success:
				let json = try? response.json()
                guard let menuJson = json?["menus"]
                    else {
                        let error = NSError.OCMError(message: nil, debugMessage: "Unexpected JSON format")
                        completion(Result.error(error))
                        return
                    }
				
				let menus = try? menuJson.flatMap(Menu.menuList)
				Storage.shared.elementsCache = json?["elementsCache"]
				completion(Result.success(menus!))
				
			default:
				let error = NSError.UnexpectedError()
				completion(Result.error(error))
			}
		}
	}
	
}
