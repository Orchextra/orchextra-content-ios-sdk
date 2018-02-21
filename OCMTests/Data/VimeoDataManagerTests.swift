//
//  VimeoDataManagerTests.swift
//  OCMTests
//
//  Created by José Estela on 19/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import XCTest
import Nimble
@testable import OCMSDK

class VimeoDataManagerTest: XCTestCase {
    
    // MARK: - Attributes
    
    var vimeoDataManager: VimeoDataManager!
    var vimeoServiceMock: VimeoServiceMock!
    var videoPersisterMock: VideoPersisterMock!
    var vimeoDataManagerOutputMock: VimeoDataManagerOutputMock!
    
    // MARK: - Test life cycle
    
    override func setUp() {
        super.setUp()
        self.vimeoServiceMock = VimeoServiceMock()
        self.vimeoDataManagerOutputMock = VimeoDataManagerOutputMock()
        self.videoPersisterMock = VideoPersisterMock()
        self.vimeoDataManager = VimeoDataManager(
            service: self.vimeoServiceMock,
            persister: self.videoPersisterMock,
            output: self.vimeoDataManagerOutputMock
        )
        
    }
    
    override func tearDown() {
        super.tearDown()
        self.vimeoDataManagerOutputMock = nil
        self.vimeoServiceMock = nil
        self.vimeoDataManager = nil
        self.videoPersisterMock = nil
    }
    
    // MARK: - Tests
    
    func test_videoDataManager_returnsCachedVideo_whenTheVideoIsNotExpired() {
        let cachedVideo = Video(
            source: "123456",
            format: .vimeo,
            previewUrl: "preview",
            videoUrl: "videoUrl"
        )
        self.videoPersisterMock.cachedVideoData = CachedVideoData(
            video: cachedVideo,
            updatedAt: Date()
        )
        self.vimeoDataManager.getVideo(idVideo: "")
        expect(self.vimeoDataManagerOutputMock.video).toNotEventually(beNil())
        expect(self.vimeoDataManagerOutputMock.error).toEventually(beNil())
        expect(self.vimeoDataManagerOutputMock.video).toEventually(equal(cachedVideo))
    }
    
    func test_videoDataManager_returnsVideoFromNetwork_whenTheVideoIsExpired() {
        let cachedVideo = Video(
            source: "123456",
            format: .vimeo,
            previewUrl: "preview",
            videoUrl: "videoUrl"
        )
        let networkVideo = Video(
            source: "987654",
            format: .vimeo,
            previewUrl: "preview_network",
            videoUrl: "videoUrl_network"
        )
        self.vimeoServiceMock.successInput = networkVideo
        self.videoPersisterMock.cachedVideoData = CachedVideoData(
            video: cachedVideo,
            updatedAt: Date().addingTimeInterval(-24 * 60 * 60).addingTimeInterval(-100)
        )
        self.vimeoDataManager.getVideo(idVideo: "")
        expect(self.vimeoDataManagerOutputMock.video).toNotEventually(beNil())
        expect(self.vimeoDataManagerOutputMock.error).toEventually(beNil())
        expect(self.vimeoDataManagerOutputMock.video).toEventually(equal(networkVideo))
    }
    
    func test_videoDataManager_savesVideoFromNetwork() {
        let networkVideo = Video(
            source: "987654",
            format: .vimeo,
            previewUrl: "preview_network",
            videoUrl: "videoUrl_network"
        )
        self.vimeoServiceMock.successInput = networkVideo
        self.vimeoDataManager.getVideo(idVideo: "")
        expect(self.videoPersisterMock.spySaveVideo.called).toEventually(equal(true))
        expect(self.videoPersisterMock.spySaveVideo.video).toEventually(equal(networkVideo))
    }
}
