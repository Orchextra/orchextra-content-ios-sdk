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
	
    let persister: ContentPersister = ContentCoreDataPersister.shared
    
	func getMenus(completion: @escaping (Result<[Menu], OCMRequestError>) -> Void) {
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
                        completion(Result.error(OCMRequestError(error: error, status: ResponseStatus.unknownError)))
                        return
                }
                let menus = try? menuJson.flatMap(Menu.menuList)
                self.saveMenusAndSections(from: json!)
                Storage.shared.elementsCache = json?["elementsCache"]
                completion(Result.success(menus!))
            default:
                let error = NSError.OCMBasicResponseErrors(response)
                completion(Result.error(error))
            }
        }
	}
    
    
    func saveMenusAndSections(from json: JSON) {
        guard
            let menuJson = json["menus"]
        else {
            return
        }
        for menu in menuJson {
            guard
                let menuModel = try? Menu.menuList(menu),
                let elements = menu["elements"],
                let elementsCache = json["elementsCache"]
            else {
                return
            }
            self.persister.save(menu: menuModel)
            for element in elements {
                self.persister.save(section: element, in: menuModel.slug)
                if let elementUrl = element["elementUrl"]?.toString(),
                    let elementCache = elementsCache["\(elementUrl)"] {
                    self.persister.save(action: elementCache, in: elementUrl)
                }
            }
        }
    }
}
