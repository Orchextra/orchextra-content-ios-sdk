//
//  ArticleViewController.swift
//  OCM
//
//  Created by Judith Medina on 17/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ArticleViewController: UIViewController, PArticleVC {
    
    @IBOutlet weak var gridArticle: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var presenter: ArticlePresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter?.viewIsReady()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: PArticleVC
    
    func show(elements: [UIView], preview: Preview?) {
        
        if let previewView = preview?.display() {
            self.stackView.addArrangedSubview(previewView)
        }
        
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
}
