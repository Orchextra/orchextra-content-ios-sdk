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
    case cancelled
    case empty
    case error(message: String)
}

protocol ContentListInteractorProtocol {
    func contentList(from path: String, forcingDownload force: Bool, completionHandler: @escaping (ContentListResult) -> Void)
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void)
}

struct ContentListInteractor: ContentListInteractorProtocol {
    
    let contentDataManager: ContentDataManager
    
    func contentList(from path: String, forcingDownload force: Bool, completionHandler: @escaping (ContentListResult) -> Void) {
        self.contentDataManager.loadContentList(forcingDownload: force, with: path) { result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            completionHandler(contentListResult)
        }
    }
    
    func contentList(matchingString string: String, completionHandler: @escaping (ContentListResult) -> Void) {
        self.contentDataManager.loadContentList(matchingString: string) {  result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            completionHandler(contentListResult)
        }
    }
    
    // MARK: - Convenience Methods
    
    func contentListResult(fromWigetListServiceResult wigetListServiceResult: Result<ContentList, NSError>) -> ContentListResult {
        switch wigetListServiceResult {
            
        case .success(let contentList):
            if !contentList.contents.isEmpty {
                return(.success(contents: contentList))
                
            } else {
                return(.empty)
            }
            
        case .error(let error):
            if error.code == NSURLErrorCancelled {
                return(.cancelled)
            } else {
                return(.error(message: error.errorMessageOCM()))
            }
        }
    }
}

fileprivate extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
