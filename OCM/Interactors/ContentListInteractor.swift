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
    func contentList(forcingDownload force: Bool)
    func contentList(matchingString string: String)
    func traceSectionLoadForContentList()
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void)
    func associatedContentPath() -> String?
    weak var output: ContentListInteractorOutput? {get set}
}

protocol ContentListInteractorOutput: class {
    func contentListLoaded(_ result: ContentListResult)
}

class ContentListInteractor: ContentListInteractorProtocol {
    
    var contentPath: String?
    weak var output: ContentListInteractorOutput?
    let contentDataManager: ContentDataManager
    let sectionInteractor: SectionInteractorProtocol
    let actionInteractor: ActionInteractorProtocol
    let contentCoodinator: ContentCoordinatorProtocol
    let ocm: OCM
    
    // MARK: - Initializer
    
    init(contentPath: String?, sectionInteractor: SectionInteractorProtocol, actionInteractor: ActionInteractorProtocol, contentCoodinator: ContentCoordinatorProtocol, contentDataManager: ContentDataManager, ocm: OCM) {
        self.contentPath = contentPath
        self.sectionInteractor = sectionInteractor
        self.actionInteractor = actionInteractor
        self.contentDataManager = contentDataManager
        self.contentCoodinator = contentCoodinator
        self.ocm = ocm
        self.contentCoodinator.addObserver(self)
    }
    
    deinit {
        self.contentCoodinator.removeObserver(self)
    }
    
    // MARK: - ContentListInteractorProtocol
    
    func contentList(forcingDownload force: Bool) {
        guard let contentPath = self.contentPath else {
            logWarn("No path for content, will not load contents")
            return
        }
        self.contentDataManager.loadContentList(forcingDownload: force, with: contentPath) { result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            self.output?.contentListLoaded(contentListResult)
        }
    }
    
    func contentList(matchingString string: String) {
        self.contentDataManager.loadContentList(matchingString: string) {  result in
            let contentListResult = self.contentListResult(fromWigetListServiceResult: result)
            self.output?.contentListLoaded(contentListResult)
        }
    }
    
    func traceSectionLoadForContentList() {
        if let contentPath = self.contentPath ,let section = self.sectionInteractor.sectionForContentWith(path: contentPath) {
            self.ocm.eventDelegate?.sectionDidLoad(section)
        }
    }

    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        self.actionInteractor.action(forcingDownload: force, with: identifier, completion: completion)
    }
    
    func associatedContentPath() -> String? {
        return self.contentPath
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
