//
//  VideoPersisterMock.swift
//  OCMTests
//
//  Created by José Estela on 19/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class VideoPersisterMock: VideoPersister {
    
    // MARK: - Attributes
    
    var cachedVideoData: CachedVideoData?
    var spySaveVideo: (called: Bool, video: Video?) = (false, nil)
    
    // MARK: - VideoPersister
    
    func save(video: Video) {
        self.spySaveVideo.called = true
        self.spySaveVideo.video = video
    }

    func loadVideo(with identifier: String) -> CachedVideoData? {
        return self.cachedVideoData
    }
}
