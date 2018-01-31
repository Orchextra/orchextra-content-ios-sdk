//
//  VideoPlayerMock.swift
//  OCMTests
//
//  Created by Jerilyn Goncalves on 30/01/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class VideoPlayerMock: VideoPlayerProtocol {
    
    // MARK: - Attributes
    var delegate: VideoPlayerDelegate?
    
    var spyShowCalled = false
    var spyPlayCalled = false
    var spyPauseCalled = false
    var spyIsPlayingCalled = false
    var spyToFullScreenCalled = false

    func show() {
        self.spyShowCalled = true
    }
    
    func play() {
        self.spyPlayCalled = true
    }
    
    func pause() {
        self.spyPauseCalled = true
    }
    
    func isPlaying() -> Bool {
        self.spyIsPlayingCalled = true
        return true
    }
    
    func toFullScreen(_ completion: (() -> Void)?) {
        self.spyToFullScreenCalled = true
    }
    
    func videoStatus() -> VideoStatus {
        return VideoStatus.stop
    }
}
