//
//  VimeoWrapperMock.swift
//  OCMTests
//
//  Created by José Estela on 7/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class VimeoWrapperMock: VimeoDataManagerInput {
    
    weak var output: VimeoDataManagerOutput?
    var getVideoResult: VimeoResult?
    
    func getVideo(idVideo: String) {
        guard let videoResult = self.getVideoResult else { return }
        self.output?.getVideoDidFinish(result: videoResult)
    }
}
