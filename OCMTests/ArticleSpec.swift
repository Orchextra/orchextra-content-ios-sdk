//
//  ArticleSpec.swift
//  OCMTests
//
//  Created by José Estela on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import Quick
import Nimble
import GIGLibrary
@testable import OCMSDK

class ArticleSpec: QuickSpec {
    
    // MARK: - Attributes
    
    var presenter: ArticlePresenter!
    var viewMock: ArticleViewMock!
    var article: Article!
    var actionInteractor: ActionInteractor!
    var reachability: ReachabilityMock!
    var ocm: OCM!
    var ocmDelegateMock: OCMDelegateMock!
    var actionScheduleManager: ActionScheduleManager!
    var actionMock: ActionMock!
    var videoInteractor: VideoInteractor!
    var vimeoWrapperMock: VimeoWrapperMock!
    var video: Video!
    var element: Element!
    var wireframeMock: OCMWireframeMock!
    var elementServiceMock: ElementServiceMock!
    
    override func spec() {
        
        beforeEach {
            self.viewMock = ArticleViewMock()
            self.article = Article(slug: "", name: "", preview: nil, elements: [])
            self.wireframeMock = OCMWireframeMock()
            self.ocm = OCM(
                wireframe: self.wireframeMock
            )
            self.ocmDelegateMock = OCMDelegateMock()
            self.actionScheduleManager = ActionScheduleManager()
            self.actionMock = ActionMock(typeAction: ActionEnumType.actionBanner)
            self.vimeoWrapperMock = VimeoWrapperMock()
            self.videoInteractor = VideoInteractor(vimeoWrapper: self.vimeoWrapperMock)
            self.elementServiceMock = ElementServiceMock()
            self.actionInteractor = ActionInteractor(
                contentDataManager: ContentDataManager(
                    contentPersister: ContentCoreDataPersister.shared,
                    menuService: MenuService(),
                    elementService: self.elementServiceMock,
                    contentListService: ContentListService(),
                    contentVersionService: ContentVersionService(),
                    contentCacheManager: ContentCacheManager.shared,
                    offlineSupport: Config.offlineSupport,
                    reachability: ReachabilityWrapper.shared
                ),
                ocm: self.ocm,
                actionScheduleManager: self.actionScheduleManager
            )
            self.presenter = ArticlePresenter(
                article: self.article,
                view: self.viewMock,
                actionInteractor: self.actionInteractor,
                articleInteractor: ArticleInteractor(
                    elementUrl: "",
                    sectionInteractor: SectionInteractor(
                        contentDataManager: .sharedDataManager
                    ),
                    ocm: self.ocm
                ),
                ocm: self.ocm,
                actionScheduleManager: self.actionScheduleManager,
                refreshManager: RefreshManager.shared,
                reachability: ReachabilityWrapper.shared,
                videoInteractor: self.videoInteractor
            )
            self.ocm.delegate = self.ocmDelegateMock
        }
        
        afterEach {
            self.viewMock = nil
            self.article = nil
            self.actionInteractor = nil
            self.presenter = nil
            self.reachability = nil
            self.ocm = nil
            self.ocmDelegateMock = nil
            self.actionScheduleManager = nil
        }
        
        describe("test article") {
            describe("when the user taps in a button") {
                beforeEach {
                    self.element = ElementButton(
                        element: ArticleElement(),
                        size: ElementButtonSize.medium,
                        elementURL: "element_url",
                        backgroundImageURL: nil
                    )
                }
                describe("and the linked action needs login") {
                    beforeEach {
                        self.elementServiceMock.error = NSError(domain: "", code: 0, userInfo: ["OCM_ERROR_MESSAGE": "requiredAuth"])
                    }
                    context("with a logged user") {
                        beforeEach {
                            self.ocm.didLogin(with: "test_id")
                        }
                        context("when the action has a view") {
                            beforeEach {
                                self.actionMock.actionView = OrchextraViewController()
                                self.elementServiceMock.action = self.actionMock
                                self.presenter.performAction(of: self.element, with: "id_of_element")
                            }
                            fit("should show the action") {
                                expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                            }
                        }
                        context("when the action doesn't have a view") {
                            beforeEach {
                                self.actionMock.actionView = nil
                                self.elementServiceMock.action = self.actionMock
                                self.presenter.performAction(of: self.element, with: "id_of_element")
                            }
                            it("should execute the action") {
                                expect(self.actionMock.spyViewCalled).toEventually(equal(true))
                            }
                        }
                    }
                    context("with an anonymous user") {
                        beforeEach {
                            self.ocm.didLogout()
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("request user auth") {
                            expect(self.ocmDelegateMock.spyContentRequiresUserAuthCalled).toEventually(equal(true))
                        }
                        describe("when login is provided") {
                            beforeEach {
                                self.ocm.didLogin(with: "test_id")
                                self.elementServiceMock.action = self.actionMock
                                self.elementServiceMock.error = nil
                                self.ocmDelegateMock.contentRequiresUserAuthenticationBlock()
                                self.actionScheduleManager.performActions(for: .login)
                            }
                            context("and the action has a view") {
                                beforeEach {
                                    self.actionMock.actionView = OrchextraViewController()
                                    self.presenter.performAction(of: self.element, with: "id_of_element")
                                }
                                it("should show the action") {
                                    expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                                }
                            }
                            context("and the action doesn't have a view") {
                                beforeEach {
                                    self.actionMock.actionView = nil
                                    self.presenter.performAction(of: self.element, with: "id_of_element")
                                }
                                it("should execute the action") {
                                    expect(self.actionMock.spyViewCalled).toEventually(equal(true))
                                }
                            }
                        }
                    }
                }
                describe("and the linked action doesn't need login") {
                    beforeEach {
                        self.elementServiceMock.action = self.actionMock
                    }
                    context("when the action has a view") {
                        beforeEach {
                            self.actionMock.actionView = OrchextraViewController()
                            self.elementServiceMock.action = self.actionMock
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("should show the action") {
                            expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                        }
                    }
                    context("when the action doesn't have a view") {
                        beforeEach {
                            self.actionMock.actionView = nil
                            self.elementServiceMock.action = self.actionMock
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("should execute the action") {
                            expect(self.actionMock.spyViewCalled).toEventually(equal(true))
                        }
                    }
                }
            }
            
            describe("when the user taps in a video") {
                context("of youtube") {
                    beforeEach {
                        self.video = Video(
                            source: "video_id",
                            format: .youtube
                        )
                        self.element = ElementVideo(
                            element: ArticleElement(),
                            video: self.video
                        )
                        self.presenter.performAction(of: self.element, with: self.video)
                    }
                    it("should show youtube view") {
                        expect(self.wireframeMock.spyShowYoutubeCalled) == true
                    }
                }
                context("of vimeo") {
                    beforeEach {
                        self.video = Video(
                            source: "video_id",
                            format: .vimeo
                        )
                        self.element = ElementVideo(
                            element: ArticleElement(),
                            video: self.video
                        )
                        self.presenter.performAction(of: self.element, with: self.video)
                    }
                    it("should show video player view") {
                        expect(self.wireframeMock.spyShowVideoPlayerCalled) == true
                    }
                }
            }
        }
    }
}
