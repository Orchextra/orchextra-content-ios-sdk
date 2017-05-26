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
    
    // MARK: - Tests
    
    //swiftlint:disable function_body_length
    override func spec() {
        
        // Tests
        describe("test contentlist") {
            
            // Setup
            beforeEach {
                self.viewMock = ContentListViewMock()
                self.contentListInteractorMock = ContentListInteractorMock()
                self.presenter = ContentListPresenter(
                    view: self.viewMock,
                    contentListInteractor: ContentListInteractor(
                        service: ContentListService(),
                        storage: Storage.shared
                    )
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
                        // ARRANGE
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                service: ContentListEmpyContentServiceMock(),
                                storage: Storage.shared
                            ),
                            defaultContentPath: ""
                        )
                        // ACT
                        presenter.viewDidLoad()
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyState.state) == .noContent
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
                                service: ContentListServiceMock(),
                                storage: Storage.shared
                            ),
                            defaultContentPath: ""
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
                                service: ContentListServiceMock(),
                                storage: Storage.shared
                            ),
                            defaultContentPath: ""
                        )
                        // ACT
                        presenter.userDidSearch(byString: "Prueba")
                        // ASSERT
                        expect(self.viewMock.spyState.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                    it("show content") {
                        // ARRANGE
                        let presenter = ContentListPresenter(
                            view: self.viewMock,
                            contentListInteractor: ContentListInteractor(
                                service: ContentListEmpyContentServiceMock(),
                                storage: Storage.shared
                            ),
                            defaultContentPath: ""
                        )
                        // ACT
                        presenter.viewDidLoad()
                        // ASSERT
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
                            service: ContentListErrorServiceMock(),
                            storage: Storage.shared
                        ),
                        defaultContentPath: ""
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
    //swiftlint:disable function_body_length
}
