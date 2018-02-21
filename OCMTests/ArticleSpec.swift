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
    var articleInteractor: ArticleInteractor!
    var reachability: ReachabilityMock!
    var ocm: OCM!
    var ocmController: OCMController!
    var ocmDelegateMock: OCMDelegateMock!
    var actionScheduleManager: ActionScheduleManager!
    var actionMock: ActionMock!
    var videoInteractor: VideoInteractor!
    var vimeoWrapperMock: VimeoWrapperMock!
    var video: Video!
    var videoPlayerMock: VideoPlayerMock!
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
            self.ocmController = OCMController()
            self.ocmController.loadWireframe(wireframe: self.wireframeMock)
            self.ocmDelegateMock = OCMDelegateMock()
            self.actionScheduleManager = ActionScheduleManager()
            self.actionMock = ActionMock(actionType: .webview)
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
                    offlineSupportConfig: Config.offlineSupportConfig,
                    reachability: ReachabilityWrapper.shared
                ),
                ocmController: self.ocmController,
                actionScheduleManager: self.actionScheduleManager
            )
            self.articleInteractor = ArticleInteractor(
                elementUrl: "",
                sectionInteractor: SectionInteractor(
                    contentDataManager: .sharedDataManager
                ),
                actionInteractor: self.actionInteractor,
                ocm: self.ocm
            )
            self.presenter = ArticlePresenter(
                article: self.article,
                view: self.viewMock,
                actionInteractor: self.actionInteractor,
                articleInteractor: self.articleInteractor,
                ocmController: self.ocmController,
                actionScheduleManager: self.actionScheduleManager,
                refreshManager: RefreshManager.shared,
                reachability: ReachabilityWrapper.shared,
                videoInteractor: self.videoInteractor
            )
            self.articleInteractor.output = self.presenter
            self.articleInteractor.actionOutput = self.presenter

            self.ocm.contentDelegate = self.ocmDelegateMock
            self.ocm.federatedAuthenticationDelegate = self.ocmDelegateMock
            self.ocm.schemeDelegate = self.ocmDelegateMock
            self.ocm.customBehaviourDelegate = self.ocmDelegateMock
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
                    self.element.customProperties = ["requiredAuth": "logged"]
                }
                describe("and the linked action needs login") {
                    beforeEach {
                        let actionMockWebView = ActionWebview(
                                                                url: URL(string:"http://gigigo.com")!,
                                                                federated: [:],
                                                                preview: nil,
                                                                shareInfo: nil,
                                                                slug: nil
                                                            )
                        self.elementServiceMock.action = actionMockWebView
                    }
                    context("with a logged user") {
                        beforeEach {
                            self.ocm.didLogin(with: "test_id") {}
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("request custom property validation") {
                            expect(self.ocmDelegateMock.spyContentNeedsCustomPropertyValidationCalled).toEventually(equal(true))
                        }
                        describe("when login property is checked") {
                            beforeEach {
                                self.ocmDelegateMock.contentNeedsCustomPropertyValidationBlock(true)
                                self.actionScheduleManager.performActions(for: "requiredAuth")
                            }
                            it("should show the action") {
                                expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                            }                            
                        }
                    }
                    context("with an anonymous user") {
                        beforeEach {
                            self.ocm.didLogout() {}
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("request custom property validation") {
                            expect(self.ocmDelegateMock.spyContentNeedsCustomPropertyValidationCalled).toEventually(equal(true))
                        }
                        describe("when login property is checked") {
                            beforeEach {
                                self.ocm.didLogin(with: "test_id") {}
                                self.ocmDelegateMock.contentNeedsCustomPropertyValidationBlock(true)
                                self.actionScheduleManager.performActions(for: "requiredAuth")
                            }
                            it("should show the action") {
                                expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                            }
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
                        self.presenter.performAction(of: self.element, with: ["video": self.video])
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
                        self.videoPlayerMock = VideoPlayerMock()
                        self.presenter.performAction(of: self.element, with: ["video": self.video, "player": self.videoPlayerMock])
                    }
                    it("should show video on full screen") {
                        expect(self.videoPlayerMock.spyToFullScreenCalled) == true
                    }
                }
            }
        }
    }
}
