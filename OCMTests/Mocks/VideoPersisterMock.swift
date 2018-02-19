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
    
    func save(video: Video) {
        
    }

    func loadVideo(with identifier: String) -> CachedVideoData? {
        return nil
    }
}
