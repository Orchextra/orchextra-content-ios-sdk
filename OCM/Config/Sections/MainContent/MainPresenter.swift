//
//  MainPresenter.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

struct MainContentViewModel {
    let contentType: ActionType
    let preview: Preview?
    let shareInfo: ShareInfo?
    let content: OrchextraViewController?
    let title: String?
    let backButtonIcon: UIImage?
}

protocol MainContentUI: class {
    func show(_ viewModel: MainContentViewModel)
    func innerScrollViewDidScroll(_ scrollView: UIScrollView)
    func showBannerAlert(_ message: String)
}

protocol MainContentComponentUI: class {
    weak var container: MainContentContainerUI? { get set }
    var returnButtonIcon: UIImage? { get }
    func titleForComponent() -> String?
    func containerScrollViewDidScroll(_ scrollView: UIScrollView)
}

protocol MainContentContainerUI: class {
    func innerScrollViewDidScroll(_ scrollView: UIScrollView)
    func showBannerAlert(_ message: String)
}

protocol MainPresenterInput: class {
    func viewIsReady()
    func userDidShare()
    func contentPreviewDidLoad()
    func contentDidLoad()
    func removeComponent()
    func performAction()
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class MainPresenter: NSObject, MainPresenterInput {
    
    weak var view: MainContentUI?
    weak var component: MainContentComponentUI?
    var preview: Preview?
    let action: Action
    let ocmController: OCMController
    
    // MARK: - Initializer

    init(action: Action, ocmController: OCMController) {
        self.preview = action.preview
        self.action = action
        self.ocmController = ocmController
    }

    // MARK: - MainPresenterInput
    
    func viewIsReady() {
        if let mainContentComponent = ActionViewer(action: self.action, ocmController: self.ocmController).mainContentComponentUI() {
            mainContentComponent.container = self
            self.component = mainContentComponent
            let viewModel = MainContentViewModel(contentType: self.action.actionType, preview: self.preview, shareInfo: self.action.shareInfo, content: mainContentComponent as? OrchextraViewController, title: self.component?.titleForComponent(), backButtonIcon: self.component?.returnButtonIcon)
            self.view?.show(viewModel)
        } else if let preview = self.preview {
            let viewModel = MainContentViewModel(contentType: self.action.actionType, preview: preview, shareInfo: self.action.shareInfo, content: nil, title: nil, backButtonIcon: UIImage.OCM.backButtonIcon)
            self.view?.show(viewModel)
        } else {
            ActionInteractor().execute(action: self.action)
        }
    }
    
    func userDidShare() {
        if let actionIdentifier = self.action.slug {
            self.ocmController.eventDelegate?.userDidShareContent(identifier: actionIdentifier, type: self.action.type ?? "")
        }
    }
    
    func contentPreviewDidLoad() {
        guard let actionIdentifier = self.action.slug else {logWarn("slug is nil"); return }
        self.ocmController.eventDelegate?.contentPreviewDidLoad(identifier: actionIdentifier, type: self.action.type ?? "")
    }
    
    func contentDidLoad() {
        guard let actionIdentifier = self.action.slug else { logWarn("slug is nil"); return }
        self.ocmController.eventDelegate?.contentDidLoad(identifier: actionIdentifier, type: self.action.type ?? "")
    }
    
    func removeComponent() {
        if let componentViewController = self.component as? UIViewController {
            componentViewController.removeFromParentViewController()
        }
    }
    
    func performAction() {
        ActionInteractor().execute(action: self.action)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.component?.containerScrollViewDidScroll(scrollView)
    }
    
}

extension MainPresenter: MainContentContainerUI {

    func innerScrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view?.innerScrollViewDidScroll(scrollView)
    }
    
    func showBannerAlert(_ message: String) {
        self.view?.showBannerAlert(message)
    }
}
