//
//  VideoPlayerWireframeRouter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol VideoPlayerWireframeInput {
    func dismiss()
}

struct VideoPlayerWireframe: VideoPlayerWireframeInput {
    
    weak var videoPlayerVC: VideoPlayerVC?
    
    func dismiss() {
        self.videoPlayerVC?.dismiss(animated: true, completion: nil)
    }
}
