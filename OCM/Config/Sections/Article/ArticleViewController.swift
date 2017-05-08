//
//  ArticleViewController.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ArticleViewController: OrchextraViewController, Instantiable, PArticleVC, ActionableElementDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var presenter: ArticlePresenter?
	
	static func identifier() -> String? {
		return "ArticleViewController"
	}
	
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.addWrappingConstraints()
        self.presenter?.viewIsReady()
    }
    
    // MARK: Helpers
    
    private func addWrappingConstraints() {
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        // Attach to top
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
        // Attach to view controller's bottom layout guide
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        // Attach to left
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        // Attach to right
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))        
    }

    // MARK: PArticleVC
    
    func show(article: Article) {
        for case var element as ActionableElement in article.elements {
            element.delegate = self
        }
        // We choose the last because Elements are created following the Decorator Pattern
        guard let last = article.elements.last else { return }
        for element in last.render() {
            self.stackView.addArrangedSubview(element)
        }
    }
    
    func showViewForAction(_ action: Action) {
        OCM.shared.wireframe.showMainComponent(with: action, viewController: self)
        //self.present(actionView, animated: true, completion: nil)
    }
    
    // MARK: - ActionElementDelegate
    
    func performAction(of element: Element, with info: String) {
        print("Perform action of \(element) with \(info)")
        self.presenter?.performAction(of: element, with: info)
    }
}
