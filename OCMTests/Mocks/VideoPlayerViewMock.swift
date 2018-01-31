//
//  VideoViewMock.swift
//  OCMTests
//
//  Created by  Eduardo Parada on 9/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class VideoPlayerMock: VideoPlayerUI {
    
    // MARK: - Attributes
    
    var spyShowLoadingIndicator = false
    var spyDismissLoadingIndicator = false
    var spyShowVideoPlayer = false
    var spyStartVideo: (called: Bool, url: URL?) = (called: false, url: nil)
    
    // MARK: - VideoPlayerUI
    
    
    func showLoadingIndicator() {
        self.spyShowLoadingIndicator = true
    }
    
    func dismissLoadingIndicator() {
        self.spyDismissLoadingIndicator = true
    }
    
    func showVideoPlayer() {
        self.spyShowVideoPlayer = true
    }
    
    func startVideo(_ url: URL) {
        self.spyStartVideo.called = true
        self.spyStartVideo.url = url
    }
}
