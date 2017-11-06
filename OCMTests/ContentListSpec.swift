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
    var ocmDelegateMock: OCMDelegateMock!
    var ocm: OCM!
    var actionScheduleManager: ActionScheduleManager!
    var contentListInteractorMock: ContentListInteractorMock!
    var sectionInteractorMock: SectionInteractorMock!
    var contentListService: ContentListServiceProtocol!
	
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
                        sectionInteractor: SectionInteractor(
                            contentDataManager: contentDataManager
                        ),
                        contentDataManager: contentDataManager
                    ),
                    ocm: self.ocm,
                    actionScheduleManager: self.actionScheduleManager
                )
                self.ocm.delegate = self.ocmDelegateMock
            }
            
            // Teardown
            afterEach {
                self.viewMock = nil
                self.presenter = nil
                self.contentListInteractorMock = nil
                self.ocm = nil
                self.ocmDelegateMock = nil
            }
            
            // MARK: - User selection
            
            describe("when user selects a content") {
                context("that doesn't need login") {
                    let content = Content(
                        slug: "content-that-needs-login",
                        tags: [
                            "tag1",
                            "tag2",
                            "tag3"
                        ],
                        name: "Prueba title",
                        media: Media(
                            url: nil,
                            thumbnail: nil
                        ),
                        elementUrl: "element/url/identifier",
                        requiredAuth: "."
                    )
                    it("show content") {
                        self.presenter.userDidSelectContent(content, viewController: UIViewController())
                        expect(self.ocmDelegateMock.spyDidOpenContent.called).toEventually(equal(true))
                        expect(self.ocmDelegateMock.spyDidOpenContent.identifier).toEventually(equal("element/url/identifier"))
                    }
                }
                context("that needs login") {
                    let content = Content(
                        slug: "content-that-needs-login",
                        tags: [
                            "tag1",
                            "tag2",
                            "tag3"
                        ],
                        name: "Prueba title",
                        media: Media(
                            url: nil,
                            thumbnail: nil
                        ),
                        elementUrl: "element/url/identifier",
                        requiredAuth: "logged"
                    )
                    context("when the user is not logged in") {
                        beforeEach {
                            self.ocm.didLogout()
                            self.presenter.userDidSelectContent(content, viewController: UIViewController())
                        }
                        
                        it("request user auth") {
                            expect(self.ocmDelegateMock.spyContentRequiresUserAuthCalled).toEventually(equal(true))
                        }
                        
                        describe("and the login is provided") {
                            beforeEach {
                                self.ocm.didLogin(with: "test_id")
                                self.ocmDelegateMock.contentRequiresUserAuthenticationBlock()
                                self.actionScheduleManager.performActions(for: .login)
                            }
                            it("show content") {
                                expect(self.ocmDelegateMock.spyDidOpenContent.called).toEventually(equal(true))
                                expect(self.ocmDelegateMock.spyDidOpenContent.identifier).toEventually(equal("element/url/identifier"))
                            }
                        }
                    }
                    context("when the user is logged in") {
                        beforeEach {
                            self.ocm.didLogin(with: "test_id")
                            self.presenter.userDidSelectContent(content, viewController: UIViewController())
                        }
                        it("show content") {
                            expect(self.ocmDelegateMock.spyDidOpenContent.called).toEventually(equal(true))
                            expect(self.ocmDelegateMock.spyDidOpenContent.identifier).toEventually(equal("element/url/identifier"))
                        }
                    }
                }
            }
            
            // MARK: - ViewDidLoad
            
            describe("when view did load") {
                beforeEach {
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        contentListInteractor: self.contentListInteractorMock,
                        ocm: self.ocm,
                        actionScheduleManager: self.actionScheduleManager,
                        defaultContentPath: ""
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
                        ocm: self.ocm,
                        actionScheduleManager: self.actionScheduleManager,
                        defaultContentPath: ""
                    )
                    presenter.applicationDidBecomeActive()
                    expect(self.contentListInteractorMock.spyContentList) == true
                }
            }
            
            // MARK: - API Response success
            
            describe("when API response success") {
                context("with empty list") {
                    it("show no content view") {
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                sectionInteractor: self.sectionInteractorMock,
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
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager,
                            defaultContentPath: ""
                        )
                        
                        presenter.viewDidLoad()
                        
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyState.state).toEventually(equal(ViewState.noContent))
                    }
                }
                context("with content") {
                    it("show content filtered by tag selected") {
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
                        
                        self.presenter.userDidFilter(byTag: ["tag1"])
                        
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content filtered by tags selected") {
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
                        
                        self.presenter.userDidFilter(byTag: ["tag1", "tag2"])
                        
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content filtered by search") {
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                sectionInteractor: self.sectionInteractorMock,
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
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager,
                            defaultContentPath: ""
                        )
                        
                        presenter.userDidSearch(byString: "Prueba")
                        
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show no content view with tag selected and no content with this tag") {
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
                        
                        self.presenter.userDidFilter(byTag: ["tag4"])
                        
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyState.state) == .noContent
                    }
                    it("show no content view with search text and no content with this string") {
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                sectionInteractor: self.sectionInteractorMock,
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
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager,
                            defaultContentPath: ""
                        )
                        // ACT
                        presenter.userDidSearch(byString: "text")
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                }
            }
            
            // MARK: - API Response failure
            
            describe("when API response failure") {
                it("show error message") {
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        contentListInteractor: ContentListInteractor(
                            sectionInteractor: self.sectionInteractorMock,
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
                        ocm: self.ocm,
                        actionScheduleManager: self.actionScheduleManager,
                        defaultContentPath: ""
                    )
                    
                    presenter.viewDidLoad()
                    
                    expect(self.viewMock.spyShowError.called).toEventually(equal(true))
                    expect(self.viewMock.spyShowError.error).toEventually(equal(kLocaleOcmErrorContent))
                }
            }
        }
    }
}
