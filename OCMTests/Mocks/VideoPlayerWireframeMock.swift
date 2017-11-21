//
//  WireframeMock.swift
//  OCMTests
//
//  Created by  Eduardo Parada on 11/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//


import Foundation
@testable import OCMSDK

class VideoPlayerWireframe: VideoPlayerWireframeInput {
    
    var spyDismiss = false
    
    func dismiss() {
        self.spyDismiss = true
    }
}
