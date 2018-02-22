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
    var elementServiceMock: ElementServiceMock!
    var sessionInteractorMock: SessionInteractorMock!
    var actionMock: ActionMock!
	
    // MARK: - Tests
    
    override func spec() {
        
        // Tests
        describe("test contentlist") {
            
            // Setup
            beforeEach {
                self.viewMock = ContentListViewMock()
                self.contentListInteractorMock = ContentListInteractorMock()
                self.sectionInteractorMock = SectionInteractorMock()
                self.sessionInteractorMock = SessionInteractorMock()
                self.ocmDelegateMock = OCMDelegateMock()
                self.ocm = OCM()
                self.elementServiceMock = ElementServiceMock()
                self.actionScheduleManager = ActionScheduleManager()
                self.actionMock = ActionMock(typeAction: ActionEnumType.actionBanner)
                let contentDataManager = ContentDataManager(
                    contentPersister: ContentPersisterMock(),
                    menuService: MenuService(),
                    elementService: self.elementServiceMock,
                    contentListService: ContentListEmpyContentServiceMock(),
                    contentCacheManager: ContentCacheManager.shared,
                    offlineSupportConfig: nil,
                    reachability: ReachabilityWrapper.shared
                )
                self.presenter = ContentListPresenter(
                    view: self.viewMock,
                    wireframe: ContentListWireframe(),
                    contentListInteractor: ContentListInteractor(
                        contentPath: "",
                        sectionInteractor: SectionInteractor(
                            contentDataManager: contentDataManager
                        ),
                        actionInteractor: ActionInteractor(
                            contentDataManager: contentDataManager,
                            ocm: self.ocm,
                            actionScheduleManager: self.actionScheduleManager
                        ),
                        contentDataManager: contentDataManager,
                        ocm: self.ocm
                    ),
                    reachability: ReachabilityWrapper.shared,
                    ocm: self.ocm
                )
                self.ocm.delegate = self.ocmDelegateMock
                self.ocm.customBehaviourDelegate = self.ocmDelegateMock
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
                    beforeEach {
                        self.elementServiceMock.action = self.actionMock
                        self.elementServiceMock.error = nil
                    }
                    it("show content") {
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
                            customProperties: [:],
                            dates: []
                        )
                        self.presenter.userDidSelectContent(content, in: UIViewController())
                        expect(self.ocmDelegateMock.spyDidOpenContent.called).toEventually(equal(true))
                        expect(self.ocmDelegateMock.spyDidOpenContent.identifier).toEventually(equal("element/url/identifier"))
                    }
                }
                context("that needs login") {
                    beforeEach {
                        self.actionMock.customProperties = ["requiredAuth": "logged"]
                        self.elementServiceMock.action = self.actionMock
                    }
                    context("when the user is not logged in") {
                        beforeEach {
                            self.ocm.didLogout()
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
                                customProperties: ["requiredAuth": "logged"],
                                dates: []
                            )
                            self.presenter.userDidSelectContent(content, in: UIViewController())
                        }
                        it("request login property validation") {
                            expect(self.ocmDelegateMock.spyContentNeedsCustomPropertyValidationCalled).toEventually(equal(true))
                        }
                        describe("when login property is validated") {
                            beforeEach {
                                self.ocm.didLogin(with: "test_id")
                                self.ocmDelegateMock.contentNeedsCustomPropertyValidationBlock(true)
                                self.actionScheduleManager.performActions(for: "requiredAuth")
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
                            self.elementServiceMock.action = self.actionMock
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
                                customProperties: [:],
                                dates: []
                            )
                            self.presenter.userDidSelectContent(content, in: UIViewController())
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
                        wireframe: ContentListWireframe(),
                        contentListInteractor: self.contentListInteractorMock,
                        reachability: ReachabilityWrapper.shared,
                        ocm: self.ocm
                    )
                    self.contentListInteractorMock.associatedContentPathString = ""
                    presenter.viewDidLoad()
                }
                
                it("show loading indicator") {
                    expect(self.viewMock.spyShowLoadingView.called).toEventually(equal(true))
                    expect(self.viewMock.spyShowLoadingView.show).toEventually(equal(true))
                }
                
                it("load content list") {
                    expect(self.contentListInteractorMock.spyContentList) == true
                }
            }
            
            // MARK: - API Response success
            
            describe("when API response success") {
                context("with empty list") {
                    it("show no content view") {
                        let contentDataManager = ContentDataManager(
                            contentPersister: ContentPersisterMock(),
                            menuService: MenuService(),
                            elementService: self.elementServiceMock,
                            contentListService: ContentListEmpyContentServiceMock(),
                            contentCacheManager: ContentCacheManager.shared,
                            offlineSupportConfig: nil,
                            reachability: ReachabilityWrapper.shared
                        )
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            wireframe: ContentListWireframe(),
                            contentListInteractor: ContentListInteractor(
                                contentPath: "",
                                sectionInteractor: self.sectionInteractorMock,
                                actionInteractor: ActionInteractor(
                                    contentDataManager: contentDataManager,
                                    ocm: self.ocm,
                                    actionScheduleManager: self.actionScheduleManager
                                ),
                                contentDataManager: contentDataManager,
                                ocm: self.ocm
                            ),
                            reachability: ReachabilityWrapper.shared,
                            ocm: self.ocm
                        )
                        
                        presenter.viewDidLoad()
                        
                        expect(self.viewMock.spyShowNoContentView.called) == true
                        expect(self.viewMock.spyShowNoContentView.called).toEventually(equal(true))
                    }
                }
                context("with content") {
                    
                    it("show content filtered by tag selected and have dates") {
                        let contentDataManager = ContentDataManager(
                            contentPersister: ContentPersisterMock(),
                            menuService: MenuService(),
                            elementService: self.elementServiceMock,
                            contentListService: ContentListServiceMock(),
                            contentCacheManager: ContentCacheManager.shared,
                            offlineSupportConfig: nil,
                            reachability: ReachabilityWrapper.shared
                        )
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            wireframe: ContentListWireframe(),
                            contentListInteractor: ContentListInteractor(
                                contentPath: "",
                                sectionInteractor: self.sectionInteractorMock,
                                actionInteractor: ActionInteractor(
                                    contentDataManager: contentDataManager,
                                    ocm: self.ocm,
                                    actionScheduleManager: self.actionScheduleManager
                                ),
                                contentDataManager: contentDataManager,
                                ocm: self.ocm
                            ),
                            reachability: ReachabilityWrapper.shared,
                            ocm: self.ocm
                        )
                        
                        presenter.viewDidLoad()
                        presenter.userDidFilter(byTag: ["withDates"])
                        
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                        let content = self.viewMock.spyShowContents.contents[0] as? Content
                        expect(content?.dates?.count) > 0
                        let contentDate = content?.dates![0]
                        let compareStart = Date(timeIntervalSince1970: 1507546800).compare((contentDate?.start)!)
                        expect(compareStart).toEventually(equal(ComparisonResult.orderedDescending))
                        let compareEnd = Date(timeIntervalSince1970: 1507546800).compare((contentDate?.end)!)
                        expect(compareEnd).toEventually(equal(ComparisonResult.orderedAscending))
                    }
                    it("show content filtered by tag selected") {
                        self.presenter.contentList = ContentList(
                            contents: [
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
                                    customProperties: [:],
                                    dates: []
                                )
                            ],
                            layout: LayoutMock(),
                            expiredAt: nil
                        )
                        
                        self.presenter.userDidFilter(byTag: ["tag1"])
                        
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content filtered by tags selected") {
                        self.presenter.contentList = ContentList(
                            contents: [
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
                                    customProperties: [:],
                                    dates: []
                                )
                            ],
                            layout: LayoutMock(),
                            expiredAt: nil
                        )
                        self.presenter.userDidFilter(byTag: ["tag1", "tag2"])
                        
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show no content view with tag selected and no content with this tag") {
                        self.presenter.contentList = ContentList(
                            contents: [
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
                                    customProperties: [:],
                                    dates: []
                                )
                            ],
                            layout: LayoutMock(),
                            expiredAt: nil
                        )
                        self.presenter.userDidFilter(byTag: ["tag4"])
                        
                        expect(self.viewMock.spyShowNoContentView.called).toEventually(equal(true))
                        expect(self.viewMock.spyShowNoContentView.show).toEventually(equal(true))
                    }
                }
            }
            
            // MARK: - API Response failure
            
            describe("when API response failure") {
                it("show error message") {
                    let contentDataManager = ContentDataManager(
                        contentPersister: ContentPersisterMock(),
                        menuService: MenuService(),
                        elementService: self.elementServiceMock,
                        contentListService: ContentListErrorServiceMock(),
                        contentCacheManager: ContentCacheManager.shared,
                        offlineSupportConfig: nil,
                        reachability: ReachabilityWrapper.shared
                    )
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        wireframe: ContentListWireframe(),
                        contentListInteractor: ContentListInteractor(
                            contentPath: "",
                            sectionInteractor: self.sectionInteractorMock,
                            actionInteractor: ActionInteractor(
                                contentDataManager: contentDataManager,
                                ocm: self.ocm,
                                actionScheduleManager: self.actionScheduleManager
                            ),
                            contentDataManager: contentDataManager,
                            ocm: self.ocm
                        ),
                        reachability: ReachabilityWrapper.shared,
                        ocm: self.ocm
                    )
                    // ACT
                    presenter.viewDidLoad()
                    // ASSERT
                    expect(self.viewMock.spyShowErrorView.called).toEventually(equal(true))
                    expect(self.viewMock.spyShowErrorView.show).toEventually(equal(true))
                }
            }
        }
    }
}
