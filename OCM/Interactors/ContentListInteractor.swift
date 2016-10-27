//
//  ContentListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

enum ContentListResult {
    case success(contents: ContentList)
    case empty
    case error(message: String)
}


struct ContentListInteractor {
    
    let service: PContentListService
    let storage: Storage
    
	func contentList(from path: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.service.getContentList(with: path) { result in
            switch result {
                
            case .success(let contentList):                
                if !contentList.contents.isEmpty {
                    completionHandler(.success(contents: contentList))
					
				} else {
                    completionHandler(.empty)
                }
                
            case .error(let error):
                completionHandler(.error(message: error.errorMessage()))
            }
        }
    }
}
