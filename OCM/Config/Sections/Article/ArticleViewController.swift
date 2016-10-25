//
//  ArticleViewController.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ArticleViewController: UIViewController, PArticleVC, UIScrollViewDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var presenter: ArticlePresenter?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.presenter?.viewIsReady()
        
    }
    
    // MARK: PArticleVC
    
    func show(elements: [UIView], preview: Preview?) {
        
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
}
