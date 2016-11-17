//
//  ContentListInteractor.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

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
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            completionHandler(contentListResult)
        }
    }
    
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.service.getContentList(matchingString: string) { result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            
            switch contentListResult {
            case .success(let contentList):
                ///DELETE GIGLIBRARY IMPORT!!!!
                ///REMOVE BOOL EXTENSION!!!!
                
                /// RANDOM SEARCH MOCK

                var filteredContents = contentList.contents.filter({ _ -> Bool in
                    return Bool.random()
                })
                
                if string.lowercased() == "nothing" {
                    filteredContents = []
                }
                
                let filteredContentList = ContentList(contents: filteredContents, layout: MosaicLayout(sizePattern: [CGSize(width: 1, height: 1)]))
                completionHandler(ContentListResult.success(contents: filteredContentList))
            default:
                completionHandler(contentListResult)
            }

        }
    }
    
    // MARK: - Convenience Methods
    
    func contentListResult(fromWigetListServiceResult wigetListServiceResult: WigetListServiceResult) -> ContentListResult {
        switch wigetListServiceResult {
            
        case .success(let contentList):
            if !contentList.contents.isEmpty {
                return(.success(contents: contentList))
                
            } else {
                return(.empty)
            }
            
        case .error(let error):
            return(.error(message: error.errorMessageOCM()))
        }
    }
}

fileprivate extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
