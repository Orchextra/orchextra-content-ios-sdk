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
        self.presenter?.viewIsReady()
    }

    // MARK: PArticleVC
    
    func show(elements: [UIView]) {
        
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
}
