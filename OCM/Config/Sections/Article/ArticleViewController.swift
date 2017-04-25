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
        guard let elements = article.elements else {
            logError(NSError(message: ("There are not elements in this article.")))
            return
        }
        
        for case var element as ActionableElement in article.elems {
            element.delegate = self
        }
        
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
    
    func show(actionView: OrchextraViewController) {
        self.present(actionView, animated: true, completion: nil)
    }
    
    // MARK: - ActionElementDelegate
    
    func performAction(of element: Element, with info: String) {
        print("Perform action of \(element) with \(info)")
        self.presenter?.performAction(of: element, with: info)
    }
}
