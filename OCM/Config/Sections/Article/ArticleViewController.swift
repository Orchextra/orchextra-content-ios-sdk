//
//  ArticleViewController.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ArticleViewController: OCMViewController, MainContentComponentUI, Instantiable {

    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicator: ImageActivityIndicator!
    
    // MARK: - Attributes
    
    var stackView: UIStackView?
    var backgroundView: UIView?
    var presenter: ArticlePresenterInput?
    private lazy var fullscreenActivityIndicatorView: FullscreenActivityIndicatorView = FullscreenActivityIndicatorView()

    static var identifier =  "ArticleViewController"
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.presenter?.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.viewWillAppear()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.isOpaque = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter?.viewWillDisappear()
    }
    
    // MARK: - MainContentComponentUI
    
    var container: MainContentContainerUI?
    var returnButtonIcon: UIImage? = Config.contentNavigationBarStyles.backButtonImage ?? UIImage.OCM.backButtonIcon
    
    func titleForComponent() -> String? {
        return self.presenter?.title()
    }
    
    func containerScrollViewDidScroll(_ scrollView: UIScrollView) {
        self.presenter?.containerScrollViewDidScroll(scrollView)
    }
    
    // MARK: Helpers
    
    private func setup() {
        self.stackView = UIStackView()
        self.stackView?.axis = .vertical
        self.stackView?.distribution = .fill
        self.stackView?.alignment = .fill
        self.stackView?.spacing = 0
        self.stackView?.backgroundColor = UIColor.clear
        var contentView = self.view
        if let backgroundViewFactory = Config.articleStyles.backgroundView {
           self.backgroundView = backgroundViewFactory.createView()
            if let backgroundViewNotNil = self.backgroundView {
                self.view.addSubview(backgroundViewNotNil)
                self.addConstraints(to: backgroundViewNotNil)
                contentView = backgroundViewNotNil
            }
        }
        
        if let stackView = self.stackView,
            let contentViewNotNil = contentView {
            self.view.addSubview(stackView)
            self.addConstraints(to: stackView, contentView: contentViewNotNil)
        }
        
        self.activityIndicator.tintColor = Config.styles.primaryColor
    }
    
    private func addConstraints(to stackView: UIStackView, contentView: UIView) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: (contentView.leadingAnchor)).isActive = true
         stackView.trailingAnchor.constraint(equalTo: (contentView.trailingAnchor)).isActive = true
        stackView.topAnchor.constraint(equalTo: (contentView.topAnchor)).isActive = true
        // Attach to view controller's bottom layout guide
        self.view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        stackView.layoutIfNeeded()
        contentView.layoutIfNeeded()
    }
    
    private func addConstraints(to backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

    }
}

// MARK: - ActionableElementDelegate

extension ArticleViewController: ActionableElementDelegate {
    
    func elementDidTap(_ element: Element, with info: Any) {
        self.presenter?.performAction(of: element, with: info)
    }
}

// MARK: - ConfigurableElementDelegate

extension ArticleViewController: ConfigurableElementDelegate {

    func elementRequiresConfiguration(_ element: Element) {
        self.presenter?.configure(element: element)
    }
    
    func soundStatusForElement(_ element: Element) -> Bool? {
        return self.presenter?.soundStatus(for: element)
    }
    
    func enableSoundForElement(_ element: Element) {
        self.presenter?.enableSound(for: element)
    }
}

// MARK: - ArticleUI

extension  ArticleViewController: ArticleUI {
    
    func show(article: Article) {
        for case var element as ActionableElement in article.elements {
            element.actionableDelegate = self
        }
        for case var element as ConfigurableElement in article.elements {
            element.configurableDelegate = self
        }
        // We choose the last because Elements are created following the Decorator Pattern
        guard let last = article.elements.last else { logWarn("last element is nil"); return }
        for element in last.render() {
            logInfo("Adding: \(element)")
            self.stackView?.addArrangedSubview(element)
        }
    }
    
    func showViewForAction(_ action: Action) {
        OCMController.shared.wireframe?.showMainComponent(with: action, viewController: self)
    }
    
    func showLoadingIndicator() {
        self.activityIndicator.startAnimating()
    }
    
    func dismissLoadingIndicator() {
        self.activityIndicator.stopAnimating()
    }
    
    func displaySpinner(show: Bool) {
        if show {
            self.fullscreenActivityIndicatorView.show(in: self.view)
        } else {
            self.fullscreenActivityIndicatorView.dismiss()
        }
    }
    
    func showAlert(_ message: String) {
        self.container?.showBannerAlert(message)
    }
}
