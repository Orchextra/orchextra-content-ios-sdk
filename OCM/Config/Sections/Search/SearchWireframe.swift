//
//  SearchRouter.swift
//  OCM
//
//  Created by José Estela on 21/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol SearchWireframeInput {
    func showSearch(in viewController: UIViewController?)
    func showSearch(in viewController: UINavigationController)
    func showAction(_ action: Action, in viewController: UIViewController)
    func dismiss()
}

class SearchWireframe: SearchWireframeInput {
    
    // MARK: - Private attributes
    
    private var viewController: UIViewController?
    private var navigationController: UINavigationController?
    
    // MARK: - Public methods
    
    func showSearch(in viewController: UIViewController? = nil) {
        guard let pincodeValidatorVC = self.loadSearchVC() else { return LogWarn("Error loading SearchVC") }
        if let viewController = viewController {
            self.viewController = viewController
            viewController.present(pincodeValidatorVC, animated: true)
        } else {
            let viewController = UIApplication.topViewController()
            viewController?.present(pincodeValidatorVC, animated: true)
            self.viewController = viewController
        }
    }
    
    func showSearch(in viewController: UINavigationController) {
        guard let pincodeValidatorVC = self.loadSearchVC() else { return LogWarn("Error loading SearchVC") }
        self.navigationController = viewController
        self.navigationController?.show(
            pincodeValidatorVC,
            sender: self
        )
    }
    
    func dismiss() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.viewController?.dismiss(animated: true)
        }
    }
    
    func showAction(_ action: Action, in viewController: UIViewController) {
        ActionInteractor().run(action: action, viewController: viewController)
    }
    
    func loadSearchVC() -> SearchVC? {
        guard let viewController = try? SearchVC.instantiateFromStoryboard() else { return nil }
        let presenter = SearchPresenter(
            view: viewController,
            wireframe: self,
            actionInteractor: ActionInteractor(
                contentDataManager: .sharedDataManager,
                ocm: OCM.shared,
                actionScheduleManager: ActionScheduleManager.shared
            ),
            searchInteractor: SearchInteractor(
                contentDataManager: .sharedDataManager
            ),
            reachability: ReachabilityWrapper.shared,
            ocm: OCM.shared
        )
        viewController.presenter = presenter
        return viewController
    }
}
