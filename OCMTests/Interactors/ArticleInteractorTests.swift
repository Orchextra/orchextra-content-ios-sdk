//
//  ArticleInteractorTests.swift
//  OCMTests
//
//  Created by Eduardo Parada on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import OCMSDK

class ArticleInteractorSpec: QuickSpec {
    
    // MARK: - Attributes
    var interactor: ArticleInteractor!
    var elementUrlMock: String!
    var sectionInteractorMock: SectionInteractorMock!
    var ocmDelegateMock: OCMDelegateMock!
    var ocm: OCM!
    
    override func spec() {
        
        beforeEach {
            self.ocm = OCM()
            self.ocmDelegateMock = OCMDelegateMock()
            self.ocm.eventDelegate = self.ocmDelegateMock
            self.sectionInteractorMock = SectionInteractorMock()
            self.elementUrlMock = "element/"
            self.interactor = ArticleInteractor(
                elementUrl: self.elementUrlMock,
                sectionInteractor: self.sectionInteractorMock,
                ocm: self.ocm
            )
        }
        
        afterEach {
            self.sectionInteractorMock = nil
            self.elementUrlMock = nil
            self.interactor = nil
        }
        
        
        describe("when view did Load") {
            context("trace Section with elementUrl and exist section") {
                beforeEach {
                    self.sectionInteractorMock.sectionReturn = Section(name: "secction", slug: "slug", elementUrl: "elementUrl", customProperties: [:])
                }
                
                it("Load For Article") {
                    self.interactor.traceSectionLoadForArticle()
                    
                    expect(self.ocmDelegateMock.spySectionDidLoad.called).toEventually(equal(true))
                    expect(self.ocmDelegateMock.spySectionDidLoad.section.slug).toEventually(equal("slug"))
                }
            }
            context("trace Section withouth elementUrl or section") {
                beforeEach {
                    self.interactor.elementUrl = nil
                    self.sectionInteractorMock.sectionReturn = nil
                }
                
                it("donn't Load For Article because elementUrl is nil") {
                    self.sectionInteractorMock.sectionReturn = Section(name: "secction2", slug: "slug2", elementUrl: "elementUrl2", customProperties: [:])
                    self.interactor.traceSectionLoadForArticle()
                    
                    expect(self.ocmDelegateMock.spySectionDidLoad.called).toEventually(equal(false))
                    expect(self.ocmDelegateMock.spySectionDidLoad.section.slug).toEventually(equal("nil"))
                }
                
                it("donn't Load For Article because section is nil") {
                    self.interactor.elementUrl = "element"
                    self.interactor.traceSectionLoadForArticle()
                    
                    expect(self.ocmDelegateMock.spySectionDidLoad.called).toEventually(equal(false))
                    expect(self.ocmDelegateMock.spySectionDidLoad.section.slug).toEventually(equal("nil"))
                }
            }
        }        
    }
}
