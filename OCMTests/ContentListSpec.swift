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
    
    // MARK: - Tests
    
    //swiftlint:disable function_body_length
    override func spec() {
        
        // Setup
        beforeSuite {
            self.viewMock = ContentListViewMock()
            self.presenter = ContentListPresenter(
                view: self.viewMock,
                contentListInteractor: ContentListInteractor(
                    service: ContentListService(),
                    storage: Storage.shared
                )
            )
        }
        
        // Teardown
        afterSuite {
            self.viewMock = nil
            self.presenter = nil
        }
        
        // Tests
        describe("test contentlist") {
            describe("if API response success") {
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
                    it("show content") {
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
                        presenter.viewDidLoad()
                        // ASSERT
                        expect(self.viewMock.spyShowContents.called) == true
                        expect(self.viewMock.spyShowContents.contents.count) > 0
                    }
                }
            }
            describe("if API response failure") {
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
