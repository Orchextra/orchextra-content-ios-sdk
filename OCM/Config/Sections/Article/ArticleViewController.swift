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
    
    func show(elements: [UIView]) {
        
        for element in elements {
            self.stackView.addArrangedSubview(element)

        }
//        let view1 = elements[0]
//        var view2 = UIView()
//        view2.backgroundColor = UIColor.black
//        view2 = addConstraints(view: view2)
//        self.stackView.addArrangedSubview(view1)
//        self.stackView.addArrangedSubview(view2)
//        print("\(self.stackView.arrangedSubviews)")
        
    }
    
    func addConstraints(view: UIView) -> UIView {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Hconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        let Vconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.height,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: 300)
        
        view.addConstraints([Hconstraint, Vconstraint])
        return view
    }
}
