//
//  ContentListSpec.swift
//  OCMTests
//
//  Created by Eduardo Parada on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//


import Foundation
import Quick
import Nimble
import GIGLibrary
@testable import OCMSDK

class ContentDataManagerSpec: QuickSpec {
    
    // MARK: - Attributes
    
    var actionScheduleManager: ActionScheduleManager!
    var ocm: OCM!
    var sectionInteractorMock: SectionInteractorMock!
    var elementServiceMock: ElementServiceMock!
    var contentDataManager: ContentDataManager!
    var contentPersisterMock: ContentPersisterMock!
    var contentListMok: ContentListErrorServiceMock!
    
    
    override func spec() {
        
        beforeEach {
            self.actionScheduleManager = ActionScheduleManager()
            self.ocm = OCM()
            self.sectionInteractorMock = SectionInteractorMock()
            self.elementServiceMock = ElementServiceMock()
            self.contentPersisterMock = ContentPersisterMock()
            self.contentListMok = ContentListErrorServiceMock()
            let offlineSupportConfig = OfflineSupportConfig(cacheSectionLimit: 10, cacheElementsPerSectionLimit: 6, cacheFirstSectionLimit: 12)
            
            self.contentDataManager = ContentDataManager(
                contentPersister: self.contentPersisterMock,
                menuService: MenuService(),
                elementService: self.elementServiceMock,
                contentListService: self.contentListMok,
                contentCacheManager: ContentCacheManager.shared,
                offlineSupportConfig: offlineSupportConfig,
                reachability: ReachabilityWrapper.shared
            )
        }
        
        afterEach {
            self.actionScheduleManager = nil
            self.ocm = nil
            self.sectionInteractorMock = nil
            self.elementServiceMock = nil
            self.contentDataManager = nil
            self.contentPersisterMock = nil
            self.contentListMok = nil
        }
        
        describe("recover items") {
            beforeEach {

            }
            
            context("when expiration date") {
                beforeEach {
                    self.contentPersisterMock.spyLoadContent.contentList = ContentList(
                        contents: [],
                        layout: LayoutFactory.layout(forJSON: JSON(from: [])),
                        expiredAt: Date(),
                        contentVersion: nil
                    )
                    self.contentListMok.spyGetContentListSuccess = JSON(from: [])
                    self.contentListMok.spyGetContentList = false
                    self.contentPersisterMock.spyLoadContent.called = false
                }
                
                it("should get item from internet") {
                    self.contentDataManager.loadContentList(forcingDownload: true, with: "", completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(true)) // This event inform that get data to internet connection
                    })
                }
            }
            
            context("when doesn't expiration date and force") {
                beforeEach {
                    self.contentPersisterMock.spyLoadContent.contentList = ContentList(
                        contents: [],
                        layout: LayoutFactory.layout(forJSON: JSON(from: [])),
                        expiredAt: Date().addingTimeInterval(10000),
                        contentVersion: nil
                    )
                    self.contentListMok.spyGetContentListSuccess = JSON(from: [])
                    self.contentListMok.spyGetContentList = false
                    self.contentPersisterMock.spyLoadContent.called = false
                }
                
                it("should get item from internet") {
                    self.contentDataManager.loadContentList(forcingDownload: true, with: "", completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(true)) // This event inform that get data to internet connection
                    })
                }
            }
            
            context("when doesn't expiration date and  doesn't force") {
                beforeEach {                    
                    self.contentPersisterMock.spyLoadContent.contentList = ContentList(
                        contents: [],
                        layout: LayoutFactory.layout(forJSON: JSON(from: [])),
                        expiredAt: Date().addingTimeInterval(10000),
                        contentVersion: nil
                    )
                    self.contentListMok.spyGetContentListSuccess = JSON(from: [])
                    self.contentListMok.spyGetContentList = false
                    self.contentPersisterMock.spyLoadContent.called = false
                }
                
                it("should get item from cache") {
                    self.contentDataManager.loadContentList(forcingDownload: false, with: "", completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(false))  // This event inform that get data to internet connection
                    })
                }
            }
            
            
            context("when expiration date is nil") {
                beforeEach {
                    self.contentPersisterMock.spyLoadContent.contentList = ContentList(
                        contents: [],
                        layout: LayoutFactory.layout(forJSON: JSON(from: [])),
                        expiredAt: nil,
                        contentVersion: nil
                    )
                    self.contentListMok.spyGetContentListSuccess = JSON(from: [])
                    self.contentListMok.spyGetContentList = false
                    self.contentPersisterMock.spyLoadContent.called = false
                }
                
                it("should get item from internet if is forcedownloading") {
                    self.contentDataManager.loadContentList(forcingDownload: true, with: "", completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(true))  // This event inform that get data to internet connection
                    })
                }
            }
        }
    }
}
