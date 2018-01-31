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


class VideoPlayerSpec: QuickSpec {
    
    // MARK: - Attributes
    
    var presenter: VideoPlayerPresenter!
    var viewMock: VideoPlayerVCMock!
    var videoInteractor: VideoInteractor!
    var video: Video!
    var vimeoWrapper: VimeoWrapper!
    var services: VimeoServiceMock!
    var wireframeMock: VideoPlayerWireframe!
    
    // MARK: - Tests
    
    override func spec() {
        
        
        // Tests
        describe("test video player") {
            
            // Setup
            beforeEach {
                self.video = Video(source: "source", format: VideoFormat.vimeo, previewUrl: "previewUrl", videoUrl: "http://google.es")
                self.wireframeMock = VideoPlayerWireframe()
                self.services = VimeoServiceMock(
                    accessToken: "accessToken",
                    errorInput: nil,
                    successInput: nil
                )
                self.vimeoWrapper = VimeoWrapper(
                    service: self.services
                )
                
                self.videoInteractor = VideoInteractor(
                    vimeoWrapper: self.vimeoWrapper
                )
                self.vimeoWrapper.output = self.videoInteractor
                
                self.viewMock = VideoPlayerVCMock()
                self.presenter = VideoPlayerPresenter(
                    view: self.viewMock,
                    wireframe: self.wireframeMock,
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
            
            describe("when view dismiss") {
                it("inform to wireframe dismiss view") {
                    self.presenter.dismiss()
                    expect(self.wireframeMock.spyDismiss).toEventually(equal(true))
                }
            }
            
            describe("when view did load") {
                it("show loading indicator") {
                    self.presenter.viewDidLoad()
                    expect(self.viewMock.spyShowLoadingIndicator).toEventually(equal(true))
                    expect(self.viewMock.spyShowVideoPlayer).toEventually(equal(true))
                }
            }
            
            describe("when view did Appear") {
                context("have url vimeo") {
                    beforeEach {
                        self.services.successInput = Video(
                            source: "source",
                            format: VideoFormat.vimeo,
                            previewUrl: "previewUrl",
                            videoUrl: "http://google.es"
                        )
                    }
                    
                    it("load video") {
                        self.presenter.viewDidAppear()
                        expect(self.viewMock.spyStartVideo.called).toEventually(equal(true))
                        expect(self.viewMock.spyStartVideo.url).toEventually(equal(URL(string: "http://google.es")))
                    }
                }
                
                context("dont have url vimeo") {
                    beforeEach {
                        self.video.videoUrl = nil
                    }
                    
                    context("success case") {
                        beforeEach {
                            self.services.errorInput = nil
                            let successInput = Video(
                                source: "source",
                                format: VideoFormat.vimeo,
                                previewUrl: "previewUrl",
                                videoUrl: "http://google.es"
                            )
                            self.services = VimeoServiceMock(
                                accessToken: "accessToken",
                                errorInput: nil,
                                successInput: successInput
                            )
                            self.vimeoWrapper = VimeoWrapper(
                                service: self.services
                            )
                            
                            self.presenter =  VideoPlayerPresenter(
                                view: self.viewMock,
                                wireframe: self.wireframeMock,
                                video: self.video,
                                videoInteractor: VideoInteractor(vimeoWrapper: self.vimeoWrapper)
                            )
                        }
                        
                        it("load video") {
                            self.presenter.viewDidAppear()
                            expect(self.viewMock.spyStartVideo.called).toEventually(equal(true))
                            expect(self.viewMock.spyStartVideo.url).toEventually(equal(URL(string: "http://google.es")))
                            expect(self.viewMock.spyDismissLoadingIndicator).toEventually(equal(true))
                        }
                    }
                    
                    context("error case") {
                        beforeEach {
                            let errorInput = NSError(
                                domain: "",
                                code: 1,
                                message: "Error message"
                            )
                            self.services = VimeoServiceMock(
                                accessToken: "accessToken",
                                errorInput: errorInput,
                                successInput: nil
                            )
                            self.vimeoWrapper = VimeoWrapper(
                                service: self.services
                            )
                            
                            self.presenter =  VideoPlayerPresenter(
                                view: self.viewMock,
                                wireframe: self.wireframeMock,
                                video: self.video,
                                videoInteractor: VideoInteractor(vimeoWrapper: self.vimeoWrapper)
                            )
                        }
                        
                        it("load video") {
                            self.presenter.viewDidAppear()
                            expect(self.viewMock.spyDismissLoadingIndicator).toEventually(equal(false))
                            expect(self.wireframeMock.spyDismiss).toEventually(equal(true))
                        }
                    }
                }
            }
            
            describe("when view did Appear") {
                context("have url youtube") {
                    beforeEach {
                        self.services.successInput = Video(
                            source: "source",
                            format: VideoFormat.youtube,
                            previewUrl: "previewUrl",
                            videoUrl: "http://google.es"
                        )
                    }
                    
                    it("load video") {
                        self.presenter.viewDidAppear()
                        expect(self.viewMock.spyStartVideo.called).toEventually(equal(true))
                        expect(self.viewMock.spyStartVideo.url).toEventually(equal(URL(string: "http://google.es")))
                    }
                }
            }
        }
    }
}
