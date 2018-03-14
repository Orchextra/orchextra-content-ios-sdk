//
//  SearchInteractor.swift
//  OCM
//
//  Created by José Estela on 27/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

protocol SearchInteractorInput {
    func searchContentList(by string: String)
}

protocol SearchInteractorOutput: class {
    func contentListLoaded(_ result: ContentListResult)
}

class SearchInteractor: SearchInteractorInput {
    
    // MARK: - Public attributes
    
    let contentDataManager: ContentDataManager
    weak var output: SearchInteractorOutput?
    
    // MARK: - Public methods
    
    init(contentDataManager: ContentDataManager, output: SearchInteractorOutput? = nil) {
        self.contentDataManager = contentDataManager
        self.output = output
    }
    
    func searchContentList(by string: String) {
        self.contentDataManager.loadContentList(matchingString: string) { result in
            switch result {
            case .success(let contentList):
                if !contentList.contents.isEmpty {
                    self.output?.contentListLoaded(.success(contents: contentList))
                } else {
                    self.output?.contentListLoaded(.empty)
                }
            case .error(let error):
                self.output?.contentListLoaded(.error(message: error.errorMessageOCM()))
            }
        }
    }
}
