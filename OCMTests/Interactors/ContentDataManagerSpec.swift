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
        
        describe("test content data manager") {
            
            context("when the content is expired") {
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
                
                it("should retrieve content from network") {
                    self.contentDataManager.loadContentList(forcingDownload: true, with: "", page: 1, items: 12, completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(true))
                    })
                }
            }
            
            context("when the content isn't expired and it is forcing download") {
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
                
                it("should retrieve content from network") {
                    self.contentDataManager.loadContentList(forcingDownload: true, with: "", page: 1, items: 12, completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(true))
                    })
                }
            }
            
            context("when the content isn't expired and it isn't forcing download") {
                beforeEach {
                    let content = Content(slug: "prueba",
                                          tags: ["tag1", "tag2", "tag3"],
                                          name: "title",
                                          media: Media(url: nil, thumbnail: nil),
                                          elementUrl: ".",
                                          customProperties: [:],
                                          dates: [])
                    let content2 = Content(slug: "prueba 2",
                                           tags: ["tag1", "tag2", "tag3"],
                                           name: "title",
                                           media: Media(url: nil, thumbnail: nil),
                                           elementUrl: ".",
                                           customProperties: [:],
                                           dates: [])
                    self.contentPersisterMock.spyLoadContent.contentList = ContentList(
                        contents: [
                            content,
                            content2,
                        ],
                        layout: LayoutFactory.layout(forJSON: JSON(from: [])),
                        expiredAt: Date().addingTimeInterval(10000),
                        contentVersion: nil
                    )
                    self.contentListMok.spyGetContentListSuccess = JSON(from: [])
                    self.contentListMok.spyGetContentList = false
                    self.contentPersisterMock.spyLoadContent.called = false
                }
                context("if the number of items in cache is less than the requested") {
                    it("and we are requesting the first page should retrieve content from cache") {
                        self.contentDataManager.loadContentList(forcingDownload: false, with: "", page: 1, items: 3, completion: { result in
                            expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                            expect(self.contentListMok.spyGetContentList).toEventually(equal(false))
                        })
                    }
                    it("and we are requesting any page different to the first should retrieve content from network") {
                        self.contentDataManager.loadContentList(forcingDownload: false, with: "", page: 2, items: 3, completion: { result in
                            expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                            expect(self.contentListMok.spyGetContentList).toEventually(equal(true))
                        })
                    }
                }
                context("if the number of items is exactly the same than the requested") {
                    it("should retrieve content from cache") {
                        self.contentDataManager.loadContentList(forcingDownload: false, with: "", page: 1, items: 2, completion: { result in
                            expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                            expect(self.contentListMok.spyGetContentList).toEventually(equal(false))
                        })
                    }
                }
            }
            
            
            context("when the expiration date is nil and it is forcing download") {
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
                
                it("should retrieve content from network") {
                    self.contentDataManager.loadContentList(forcingDownload: true, with: "", page: 1, items: 12, completion: { result in
                        expect(self.contentPersisterMock.spyLoadContent.called).toEventually(equal(true))
                        expect(self.contentListMok.spyGetContentList).toEventually(equal(true))  // This event inform that get data to internet connection
                    })
                }
            }
        }
    }
}
