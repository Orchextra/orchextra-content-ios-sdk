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
    var currentScrollOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.gridArticle.delegate = self
        self.gridArticle.isPagingEnabled = true
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
    
    // MARK: UISCrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        if currentScrollOffset > self.view.frame.height {
            scrollView.isPagingEnabled = false
        } else {
            scrollView.isPagingEnabled = true
        }
        self.currentScrollOffset = scrollView.contentOffset.y
    }
}
