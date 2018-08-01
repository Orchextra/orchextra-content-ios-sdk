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

protocol ContentListInteractorProtocol {
    func contentList(forcingDownload force: Bool, page: Int, items: Int)
    func contentVersionUpdated()
    func traceSectionLoadForContentList()
    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void)
    func associatedContentPath() -> String?
    func associatedSectionPath() -> String?
    func contentVersion() -> String?
    var output: ContentListInteractorOutput? {get set}
}

protocol ContentListInteractorOutput: class {
    func contentListLoaded(_ result: ContentListResult)
    func newContentAvailable()
    func numberOfItemsPerPage() -> Int
}

class ContentListInteractor: ContentListInteractorProtocol {
    
    var contentPath: String?
    weak var output: ContentListInteractorOutput?
    let contentDataManager: ContentDataManager
    let sectionInteractor: SectionInteractorProtocol
    let actionInteractor: ActionInteractorProtocol
    let contentCoordinator: ContentCoordinator?
    let ocm: OCM
    let reachability: ReachabilityInput
    
    // MARK: Private properties
    private var preloadedContentList: ContentList?
    
    // MARK: - Initializer
    
    init(contentPath: String?, sectionInteractor: SectionInteractorProtocol, actionInteractor: ActionInteractorProtocol, contentDataManager: ContentDataManager, contentCoordinator: ContentCoordinator?, ocm: OCM, reachability: ReachabilityInput) {
        self.contentPath = contentPath
        self.sectionInteractor = sectionInteractor
        self.actionInteractor = actionInteractor
        self.contentDataManager = contentDataManager
        self.contentCoordinator = contentCoordinator
        self.ocm = ocm
        self.reachability = reachability
        self.contentCoordinator?.addObserver(self)
    }
    
    deinit {
        self.contentCoordinator?.removeObserver(self)
    }
    
    // MARK: - ContentListInteractorProtocol
    
    func contentList(forcingDownload force: Bool, page: Int, items: Int) {
        guard let contentPath = self.contentPath else {
            LogWarn("No path for content, will not load contents")
            return
        }
        self.contentDataManager.loadContentList(forcingDownload: force, with: contentPath, page: page, items: items) { result in
            let contentListResult = self.handleContentListResult(of: contentPath, result: result)
            self.output?.contentListLoaded(contentListResult)
        }
    }
    
    func contentVersionUpdated() {
        guard let contentPath = self.contentPath else {
            LogWarn("No path for content, will not pre-load contents")
            return
        }
        // When the version changes, the content list is pre-loaded and stored in memory until the user taps on the new content button
        self.contentDataManager.preloadContentList(
            with: contentPath,
            page: 1,
            items: self.output?.numberOfItemsPerPage() ?? 9,
            completion: { _ in
                self.output?.newContentAvailable()
            }
        )
    }
    
    func traceSectionLoadForContentList() {
        if let contentPath = self.contentPath, let section = self.sectionInteractor.sectionForContentWith(path: contentPath) {
            self.ocm.eventDelegate?.sectionDidLoad(section)
        }
    }

    func action(forcingDownload force: Bool, with identifier: String, completion: @escaping (Action?, Error?) -> Void) {
        if self.reachability.isReachable() || (Config.offlineSupportConfig != nil && ContentCacheManager.shared.cachedArticle(for: identifier) != nil) {
            self.actionInteractor.action(forcingDownload: force, with: identifier, completion: completion)
        } else {
            completion(nil, OCMError.openContentWithNoInternet)
        }
    }
    
    func associatedContentPath() -> String? {
        return self.contentPath
    }
    
    func associatedSectionPath() -> String? {
        if let contentPath = self.contentPath, let section = self.sectionInteractor.sectionForContentWith(path: contentPath) {
            return section.elementUrl
        }
        return nil
    }
    
    func contentVersion() -> String? {
        if let contentPath = self.contentPath, let contentVersion = self.contentDataManager.loadContentVersion(with: contentPath) {
            return contentVersion
        }
        return nil
    }

    // MARK: - Private Methods
    
    private func handleContentListResult(of contentPath: String, result: Result<ContentList, NSError>) -> ContentListResult {
        switch result {
        case .success(let contentList):
            if self.contentVersion() != contentList.contentVersion || self.contentDataManager.contentPersister.loadSectionForContent(with: contentPath)?.contentVersion != contentList.contentVersion || self.isExpiredContent(content: contentList) {
                self.contentVersionUpdated()
            }
            if !contentList.contents.isEmpty {
                return(.success(contents: contentList))
            } else {
                return(.empty)
            }
        case .error(let error):
            return(.error(message: error.errorMessageOCM()))
        }
    }
    
    private func isExpiredContent(content: ContentList) -> Bool {
        guard
            let date = content.expiredAt else {
                return false
        }
        switch Date().compare(date) {
        case .orderedAscending:
            return false
        default:
            return true
        }
    }
}
