//
//  VideoPlayerWireframeRouter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct VideoPlayerWireframe {
    
    /// Method to show the VideoPlayerWireframe section
    ///
    /// - Returns: VideoPlayerWireframe View Controller with all dependencies
    func showVideoPlayerWireframe() -> VideoPlayerVC? {
        guard let viewController = try? VideoPlayerVC.instantiateFromStoryboard() else { return nil }
        let wireframe = VideoPlayerWireframe()
        let presenter = VideoPlayerPresenter(
            view: viewController,
            wireframe: wireframe
        )
        viewController.presenter = presenter
        return viewController
    }
}
