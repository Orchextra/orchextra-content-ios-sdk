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
        self.presenter?.viewIsReady()
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
    
    // MARK: - ActionableElementDelegate
    
    func performAction(of element: Element, with info: Any) {
        
        self.presenter?.performAction(of: element, with: info)
    }
}
