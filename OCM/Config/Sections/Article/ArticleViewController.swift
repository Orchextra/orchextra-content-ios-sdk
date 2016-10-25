//
//  ArticleViewController.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ArticleViewController: UIViewController, Instantiable, PArticleVC, UIScrollViewDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var presenter: ArticlePresenter?
	
	static func identifier() -> String? {
		return "ArticleViewController"
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewIsReady()
    }
    
    @IBAction func didTap(_ backButton: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    // MARK: PArticleVC
    
    func show(elements: [UIView], preview: Preview?) {
        
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
}
