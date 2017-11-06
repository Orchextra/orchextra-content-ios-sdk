//
//  ContentList.swift
//  OCM
//
//  Created by José Estela on 8/2/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Quick
import Nimble
@testable import OCMSDK

class ContentListSpec: QuickSpec {
    
    // MARK: - Attributes
    
    var presenter: ContentListPresenter!
    var viewMock: ContentListViewMock!
    var contentListInteractorMock: ContentListInteractorMock!
    var sectionInteractorMock: SectionInteractorMock!
<<<<<<< HEAD
	
=======
    var contentListService: ContentListServiceProtocol!
>>>>>>> feature/trace_content_load
	
    // MARK: - Tests
    
    override func spec() {
        
        // Tests
        describe("test contentlist") {
            
            // Setup
            beforeEach {
                self.viewMock = ContentListViewMock()
                self.contentListInteractorMock = ContentListInteractorMock()
                self.sectionInteractorMock = SectionInteractorMock()
                self.ocmDelegateMock = OCMDelegateMock()
                self.ocm = OCM()
                self.actionScheduleManager = ActionScheduleManager()
                
                let contentDataManager = ContentDataManager(
                    contentPersister: ContentPersisterMock(),
                    menuService: MenuService(),
                    elementService: ElementService(),
                    contentListService: ContentListEmpyContentServiceMock(),
                    contentCacheManager: ContentCacheManager.shared,
                    offlineSupport: false,
                    reachability: ReachabilityWrapper.shared
                )
                self.presenter = ContentListPresenter(
                    view: self.viewMock,
                    contentListInteractor: ContentListInteractor(
                        contentDataManager: contentDataManager
                    ),
                    sectionInteractor: SectionInteractor(
                        contentDataManager: contentDataManager
<<<<<<< HEAD
                    )
=======
                    ),
                    ocm: self.ocm,
                    actionScheduleManager: self.actionScheduleManager
>>>>>>> feature/trace_content_load
                )
            }
            
            // Teardown
            afterEach {
                self.viewMock = nil
                self.presenter = nil
                self.contentListInteractorMock = nil
            }
            
            // MARK: - ViewDidLoad
            
            describe("when view did load") {
                beforeEach {
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        contentListInteractor: self.contentListInteractorMock,
<<<<<<< HEAD
                        defaultContentPath: "",
                        sectionInteractor: self.sectionInteractorMock
=======
                        sectionInteractor: self.sectionInteractorMock,
                        ocm: self.ocm,
                        actionScheduleManager: self.actionScheduleManager,
                        defaultContentPath: ""
>>>>>>> feature/trace_content_load
                    )
                    presenter.viewDidLoad()
                }
                
                it("show loading indicator") {
                    expect(self.viewMock.spyState.called).toEventually(equal(true))
                    expect(self.viewMock.spyState.state).toEventually(equal(ViewState.loading))
                }
                
                it("load content list") {
                    expect(self.contentListInteractorMock.spyContentList) == true
                }
            }
            
            // MARK: - ApplicationDidBecomeActive
            
            describe("when application did become active") {
                it("load content list") {
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        contentListInteractor: self.contentListInteractorMock,
<<<<<<< HEAD
                        defaultContentPath: "",
                        sectionInteractor: self.sectionInteractorMock
=======
                        sectionInteractor: self.sectionInteractorMock,
                        ocm: self.ocm,
                        actionScheduleManager: self.actionScheduleManager,
                        defaultContentPath: ""
>>>>>>> feature/trace_content_load
                    )
                    presenter.applicationDidBecomeActive()
                    expect(self.contentListInteractorMock.spyContentList) == true
                }
            }
            
            // MARK: - API Response success
            
            describe("when API response success") {
                context("with empty list") {
                    it("show no content view") {
                        // ARRANGE
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                contentDataManager: ContentDataManager(
                                    contentPersister: ContentPersisterMock(),
                                    menuService: MenuService(),
                                    elementService: ElementService(),
                                    contentListService: ContentListEmpyContentServiceMock(),
                                    contentCacheManager: ContentCacheManager.shared,
                                    offlineSupport: false,
                                    reachability: ReachabilityWrapper.shared
                                )
                            ),
<<<<<<< HEAD
                            defaultContentPath: "",
                            sectionInteractor: self.sectionInteractorMock
=======
                            sectionInteractor: self.sectionInteractorMock,
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager,
                            defaultContentPath: ""
>>>>>>> feature/trace_content_load
                        )
                        // ACT
                        presenter.viewDidLoad()
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyState.state).toEventually(equal(ViewState.noContent))
                    }
                }
                context("with content") {
                    it("show content filtered by tag selected") {
                        // ARRANGE
                        self.presenter.contents = [
                            Content(
                                slug: "prueba",
                                tags: [
                                    "tag1",
                                    "tag2",
                                    "tag3"
                                ],
                                name: "title",
                                media: Media(
                                    url: nil,
                                    thumbnail: nil
                                ),
                                elementUrl: ".",
                                requiredAuth: "."
                            )
                        ]
                        // ACT
                        self.presenter.userDidFilter(byTag: ["tag1"])
                        // ASSERT
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content filtered by tags selected") {
                        // ARRANGE
                        self.presenter.contents = [
                            Content(
                                slug: "prueba",
                                tags: [
                                    "tag1",
                                    "tag2",
                                    "tag3"
                                ],
                                name: "name",
                                media: Media(
                                    url: nil,
                                    thumbnail: nil
                                ),
                                elementUrl: ".",
                                requiredAuth: "."
                            )
                        ]
                        // ACT
                        self.presenter.userDidFilter(byTag: ["tag1", "tag2"])
                        // ASSERT
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content filtered by search") {
                        // ARRANGE
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                contentDataManager: ContentDataManager(
                                    contentPersister: ContentPersisterMock(),
                                    menuService: MenuService(),
                                    elementService: ElementService(),
                                    contentListService: ContentListServiceMock(),
                                    contentCacheManager: ContentCacheManager.shared,
                                    offlineSupport: false,
                                    reachability: ReachabilityWrapper.shared
                                )
                            ),
<<<<<<< HEAD
                            defaultContentPath: "",
                            sectionInteractor: self.sectionInteractorMock
=======
                            sectionInteractor: self.sectionInteractorMock,
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager,
                            defaultContentPath: ""
>>>>>>> feature/trace_content_load
                        )
                        // ACT
                        presenter.userDidSearch(byString: "Prueba")
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show no content view with tag selected and no content with this tag") {
                        // ARRANGE
                        self.presenter.contents = [
                            Content(
                                slug: "prueba",
                                tags: [
                                    "tag1",
                                    "tag2",
                                    "tag3"
                                ],
                                name: "title",
                                media: Media(
                                    url: nil,
                                    thumbnail: nil
                                ),
                                elementUrl: ".",
                                requiredAuth: "."
                            )
                        ]
                        // ACT
                        self.presenter.userDidFilter(byTag: ["tag4"])
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyState.state) == .noContent
                    }
                    it("show no content view with search text and no content with this string") {
                        // ARRANGE
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                contentDataManager: ContentDataManager(
                                    contentPersister: ContentPersisterMock(),
                                    menuService: MenuService(),
                                    elementService: ElementService(),
                                    contentListService: ContentListServiceMock(),
                                    contentCacheManager: ContentCacheManager.shared,
                                    offlineSupport: false,
                                    reachability: ReachabilityWrapper.shared
                                )

                            ),
<<<<<<< HEAD
                            defaultContentPath: "",
                            sectionInteractor: self.sectionInteractorMock
=======
                            sectionInteractor: self.sectionInteractorMock,
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager,
                            defaultContentPath: ""
>>>>>>> feature/trace_content_load
                        )
                        // ACT
                        presenter.userDidSearch(byString: "Prueba")
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content") {
<<<<<<< HEAD
                        // ARRANGE
                        let contentDataManager = ContentDataManager(
                            contentPersister: ContentPersisterMock(),
                            menuService: MenuService(),
                            elementService: ElementService(),
                            contentListService: ContentListEmpyContentServiceMock(),
                            contentCacheManager: ContentCacheManager.shared,
                            offlineSupport: false,
                            reachability: ReachabilityWrapper.shared
                        )
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                contentDataManager: contentDataManager
                            ),
                            defaultContentPath: "",
                            sectionInteractor: SectionInteractor(contentDataManager: contentDataManager)
                        )
                        // ACT
                        presenter.viewDidLoad()
                        // ASSERT
=======
                        self.presenter.defaultContentPath = ""
                        self.presenter.viewDidLoad()
>>>>>>> feature/trace_content_load
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyState.state) == .noContent
                    }
                }
            }
            
            // MARK: - API Response failure
            
            describe("when API response failure") {
                it("show error message") {
                    // ARRANGE
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        contentListInteractor: ContentListInteractor(
                            contentDataManager: ContentDataManager(
                                contentPersister: ContentPersisterMock(),
                                menuService: MenuService(),
                                elementService: ElementService(),
                                contentListService: ContentListErrorServiceMock(),
                                contentCacheManager: ContentCacheManager.shared,
                                offlineSupport: false,
                                reachability: ReachabilityWrapper.shared
                            )

                        ),
<<<<<<< HEAD
                        defaultContentPath: "",
                        sectionInteractor: self.sectionInteractorMock
=======
                        sectionInteractor: self.sectionInteractorMock,
                        ocm: self.ocm,
                        actionScheduleManager: self.actionScheduleManager,
                        defaultContentPath: ""
>>>>>>> feature/trace_content_load
                    )
                    // ACT
                    presenter.viewDidLoad()
                    // ASSERT
                    expect(self.viewMock.spyShowError.called).toEventually(equal(true))
                    expect(self.viewMock.spyShowError.error).toEventually(equal(kLocaleOcmErrorContent))
                }
            }
        }
    }
}
