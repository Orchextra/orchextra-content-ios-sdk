//
//  VimeoPresenter.swift
//  OCMTests
//
//  Created by  Eduardo Parada on 9/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Quick
import Nimble
@testable import OCMSDK


class VimeoPresenterSpec: QuickSpec {
    
    // MARK: - Attributes
    
    var presenter: VideoPlayerPresenter!
    var viewMock: VideoPlayerViewMock!
    var videoInteractor: VideoInteractor!
    var video: Video!
    var vimeoWrapper: VimeoWrapper!
    
    // MARK: - Tests
    
    override func spec() {
        
        
        // Tests
        describe("test contentlist") {
            
            // Setup
            beforeEach {
                self.vimeoWrapper = VimeoWrapper(
                    service: VimeoServiceMock(
                        accessToken: "accessToken",
                        errorInput: nil,
                        successInput: nil
                    )
                )
                
                self.videoInteractor = VideoInteractor(
                    vimeoWrapper: self.vimeoWrapper
                )
                self.vimeoWrapper.output = self.videoInteractor
                
                self.viewMock = VideoPlayerViewMock()
                self.presenter = VideoPlayerPresenter(
                    view: self.viewMock,
                    wireframe: VideoPlayerWireframe(),
                    video: self.video,
                    videoInteractor: self.videoInteractor
                )
            }
            
            
            // Teardown
            afterEach {
                self.presenter = nil
                self.viewMock = nil
                self.videoInteractor = nil
                self.video = nil
                self.vimeoWrapper = nil
            }
            
            // MARK: - ViewDidLoad
            
            
            describe("when view did load") {
                it("show loading indicator") {
                    expect(self.viewMock.spyShowLoadingIndicator).toEventually(equal(true))
                }
            }
            
            
            describe("when view did Appear") {
                /*
                beforeEach {
                    let presenter = ContentListPresenter(
                        view: self.viewMock,
                        contentListInteractor: self.contentListInteractorMock,
                        defaultContentPath: ""
                    )
                    presenter.viewDidLoad()
                }*/
                
                context("have url") {
                    it("load video") {
                        expect(self.viewMock.spyState.called).toEventually(equal(true))
                        expect(self.viewMock.spyState.state).toEventually(equal(ViewState.loading))
                    }
                
         
                }
            }
            
            
            
            
        }
    }
}
