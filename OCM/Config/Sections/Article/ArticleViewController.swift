//
//  ArticleViewController.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ArticleViewController: OrchextraViewController, Instantiable, PArticleVC {
    
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
        // TODO: Document !!!
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.bottomLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        // Attach to left
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        // Attach to right
        self.view.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))        
    }

    // MARK: PArticleVC
    
    func show(elements: [UIView]) {
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
}
