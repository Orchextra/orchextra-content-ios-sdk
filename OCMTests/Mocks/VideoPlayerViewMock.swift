//
//  VideoViewMock.swift
//  OCMTests
//
//  Created by  Eduardo Parada on 9/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class VideoPlayerViewMock: VideoPlayerUI {
    
    // MARK: - Attributes
    
    var spyShowLoadingIndicator = false
    var spyDismissLoadingIndicator = false
    var spyVideo: (called: Bool, url: URL?) = (called: false, url: nil)
    
    // MARK: - VideoPlayerUI
    
    
    func showLoadingIndicator() {
        self.spyShowLoadingIndicator = true
    }
    
    func dismissLoadingIndicator() {
        self.spyDismissLoadingIndicator = true
    }
    
    func startVideo(_ url: URL) {
        self.spyVideo.called = true
        self.spyVideo.url = url
    }
}
