//
//  MainContentViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class MainContentViewController: UIViewController, PMainContent {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var presenter: MainPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewIsReady()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func show(preview: Preview?, action: Action) {
        
        if let previewView = preview?.display() {
            self.stackView.addArrangedSubview(previewView)
        }
        
        if let viewAction = action.view() {
            self.stackView.addArrangedSubview(viewAction.view)
        }
        print(self.scrollView.contentSize)
    }
}
