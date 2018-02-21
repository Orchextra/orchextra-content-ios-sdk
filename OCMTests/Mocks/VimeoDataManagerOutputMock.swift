//
//  VimeoDataManagerOutputMockl.swift
//  OCMTests
//
//  Created by José Estela on 19/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class VimeoDataManagerOutputMock: VimeoDataManagerOutput {
    
    // MARK: - Attributes
    
    var video: Video?
    var error: Error?
    
    // MARK: - VimeoDataManagerOutput
    
    func getVideoDidFinish(result: VimeoResult) {
        switch result {
        case .succes(video: let video):
            self.video = video
        case .error(error: let error):
            self.error = error
        }
    }
}
