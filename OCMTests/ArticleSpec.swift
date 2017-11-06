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
    var actionInteractorMock: ActionInteractorMock!
    var reachability: ReachabilityMock!
    var ocm: OCM!
    var ocmDelegateMock: OCMDelegateMock!
    var actionScheduleManager: ActionScheduleManager!
    var actionMock: ActionMock!
    var element: Element!
    
    override func spec() {
        
        beforeEach {
            self.viewMock = ArticleViewMock()
            self.article = Article(slug: "", name: "", preview: nil, elements: [])
            self.actionInteractorMock = ActionInteractorMock()
            self.ocm = OCM()
            self.ocmDelegateMock = OCMDelegateMock()
            self.actionScheduleManager = ActionScheduleManager()
            self.actionMock = ActionMock()
            self.presenter = ArticlePresenter(
                article: self.article,
                view: self.viewMock,
                actionInteractor: self.actionInteractorMock,
                ocm: self.ocm,
                actionScheduleManager: self.actionScheduleManager,
                articleInteractor: ArticleInteractor(
                    elementUrl: "",
                    sectionInteractor: SectionInteractor(
                        contentDataManager: .sharedDataManager
                    )
                )
            )
            self.ocm.delegate = self.ocmDelegateMock
        }
        
        afterEach {
            self.viewMock = nil
            self.article = nil
            self.actionInteractorMock = nil
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
                        self.actionInteractorMock.completion.error = NSError(domain: "", code: 0, userInfo: ["OCM_ERROR_MESSAGE": "requiredAuth"])
                    }
                    context("with a logged user") {
                        beforeEach {
                            self.ocm.didLogin(with: "test_id")
                        }
                        context("when the action has a view") {
                            beforeEach {
                                self.actionMock.actionView = OrchextraViewController()
                                self.actionInteractorMock.completion.action = self.actionMock
                                self.presenter.performAction(of: self.element, with: "id_of_element")
                            }
                            it("show the action") {
                                expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                            }
                        }
                        context("when the action doesn't have a view") {
                            beforeEach {
                                self.actionMock.actionView = nil
                                self.actionInteractorMock.completion.action = self.actionMock
                                self.presenter.performAction(of: self.element, with: "id_of_element")
                            }
                            it("execute the action") {
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
                                self.actionInteractorMock.completion.action = self.actionMock
                                self.actionInteractorMock.completion.error = nil
                                self.ocmDelegateMock.contentRequiresUserAuthenticationBlock()
                                self.actionScheduleManager.performActions(for: .login)
                            }
                            context("and the action has a view") {
                                beforeEach {
                                    self.actionMock.actionView = OrchextraViewController()
                                    self.presenter.performAction(of: self.element, with: "id_of_element")
                                }
                                it("show the action") {
                                    expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                                }
                            }
                            context("and the action doesn't have a view") {
                                beforeEach {
                                    self.actionMock.actionView = nil
                                    self.presenter.performAction(of: self.element, with: "id_of_element")
                                }
                                it("execute the action") {
                                    expect(self.actionMock.spyViewCalled).toEventually(equal(true))
                                }
                            }
                        }
                    }
                }
                describe("and the linked action doesn't need login") {
                    beforeEach {
                        self.actionInteractorMock.completion.0 = self.actionMock
                    }
                    context("when the action has a view") {
                        beforeEach {
                            self.actionMock.actionView = OrchextraViewController()
                            self.actionInteractorMock.completion.action = self.actionMock
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("show the action") {
                            expect(self.viewMock.spyShowViewForAction.called).toEventually(equal(true))
                        }
                    }
                    context("when the action doesn't have a view") {
                        beforeEach {
                            self.actionMock.actionView = nil
                            self.actionInteractorMock.completion.action = self.actionMock
                            self.presenter.performAction(of: self.element, with: "id_of_element")
                        }
                        it("execute the action") {
                            expect(self.actionMock.spyViewCalled).toEventually(equal(true))
                        }
                    }
                }
            }
            
        }
    }
}
