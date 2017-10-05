//
//  VimeoWireframeRouter.swift
//  OCM
//
//  Created by José Estela on 5/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct VimeoWireframe {
    
    /// Method to show the VimeoWireframe section
    ///
    /// - Returns: VimeoWireframe View Controller with all dependencies
    func showVimeoWireframe() -> VimeoVC? {
        guard let viewController = try? VimeoVC.instantiateFromStoryboard() else { return nil }
        let wireframe = VimeoWireframe()
        let presenter = VimeoPresenter(
            view: viewController,
            wireframe: wireframe
        )
        viewController.presenter = presenter
        return viewController
    }
}
