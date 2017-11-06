//
//  SectionInteractor.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 31/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

protocol SectionInteractorProtocol {
    func sectionForContentWith(path: String) -> Section?
    func sectionForActionWith(identifier: String) -> Section?
}

class SectionInteractor: SectionInteractorProtocol {
    
    let contentDataManager: ContentDataManager
    
    // MARK: Initializer
    
    init(contentDataManager: ContentDataManager) {
        self.contentDataManager = contentDataManager
    }

    // MARK: SectionInteractorProtocol
    
    func sectionForContentWith(path: String) -> Section? {
        let section = self.contentDataManager.loadSection(with: path)
        return section
    }
    
    func sectionForActionWith(identifier: String) -> Section? {
        let section = self.contentDataManager.loadSectionForAction(with: identifier)
        return section
    }
    
}
