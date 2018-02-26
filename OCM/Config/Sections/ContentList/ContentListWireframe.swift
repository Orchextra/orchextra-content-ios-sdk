//
//  ContentsRouter.swift
//  OCM
//
//  Created by José Estela on 22/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ContentListWireframeInput {
    func showContents(in viewController: UIViewController?)
    func showContents(in viewController: UINavigationController)
    func showAction(_ action: Action, in viewController: UIViewController)
    func dismiss()
}

class ContentListWireframe: ContentListWireframeInput {
    
    // MARK: - Private attributes
    
    private var viewController: UIViewController?
    private var navigationController: UINavigationController?
    
    // MARK: - Public methods
    
    func showContents(in viewController: UIViewController? = nil) {
        guard let pincodeValidatorVC = self.loadContents() else { return LogWarn("Error loading ContentListVC") }
        if let viewController = viewController {
            self.viewController = viewController
            viewController.present(pincodeValidatorVC, animated: true)
        } else {
            let viewController = UIApplication.topViewController()
            viewController?.present(pincodeValidatorVC, animated: true)
            self.viewController = viewController
        }
    }
    
    func showContents(in viewController: UINavigationController) {
        guard let pincodeValidatorVC = self.loadContents() else { return LogWarn("Error loading ContentListVC") }
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
    
    func loadContents(path: String? = nil) -> ContentListVC? {
        guard let viewController = try? ContentListVC.instantiateFromStoryboard() else { return nil }
        let presenter = ContentListPresenter(
            view: viewController,
            wireframe: self,
            contentListInteractor: ContentListInteractor(
                contentPath: path,
                sectionInteractor: SectionInteractor(
                    contentDataManager: .sharedDataManager
                ),
                actionInteractor: ActionInteractor(
                    contentDataManager: .sharedDataManager,
                    ocm: OCM.shared,
                    actionScheduleManager: ActionScheduleManager.shared
                ),
                contentDataManager: .sharedDataManager,
                contentCoordinator: ContentCoordinator.shared,
                ocm: OCM.shared
            ),
            reachability: ReachabilityWrapper.shared,
            ocm: OCM.shared
        )
        viewController.presenter = presenter
        return viewController
    }
}
