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
    
    @IBOutlet weak var gridArticle: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var presenter: ArticlePresenter?
    
    var previewInteractionController: PreviewInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gridArticle.delegate = self
        self.presenter?.viewIsReady()
    }
    
    // MARK: PArticleVC
    
    func show(elements: [UIView], preview: Preview?) {
        
        if let previewView = preview?.display(), let preview = preview {
            self.stackView.addArrangedSubview(previewView)
            self.previewInteractionController = PreviewInteractionController(scroll: self.gridArticle, previewView: previewView, preview: preview)
        }
        
        for element in elements {
            self.stackView.addArrangedSubview(element)
        }
    }
}
