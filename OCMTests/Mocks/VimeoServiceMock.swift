//
//  VimeoServiceMock.swift
//  OCMTests
//
//  Created by  Eduardo Parada on 9/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary
@testable import OCMSDK

struct VimeoServiceMock: VimeoServiceInput {
    
    let accessToken: String
    
    // INPUT
    var errorInput: NSError?
    var successInput: Video?
    
    
    // MARK: - Public methods
    
    func getVideo(with idVideo: String, completion: @escaping (Result<Video, NSError>) -> Void) {
        if self.errorInput != nil {
            completion(Result.error(self.errorInput!))
        } else {
            guard let success = self.successInput else { logWarn("successInput is nil"); return }
            completion(Result.success(success))
        }
    }
}
