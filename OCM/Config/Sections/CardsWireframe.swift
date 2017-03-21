//
//  CardsRouter.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct CardsWireframe {
    
    /// Method to show the Cards section
    ///
    /// - Returns: Cards View Controller with all dependencies
    func showCards() -> CardsVC? {
        guard let viewController = try? Instantiator<CardsVC>().viewController() else { return nil }
        let wireframe = CardsWireframe()
        let presenter = CardsPresenter(
            view: viewController,
            wireframe: wireframe,
            elements: []
        )
        viewController.presenter = presenter
        return viewController
    }
}
