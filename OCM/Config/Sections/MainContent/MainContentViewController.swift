//
//  MainContentViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class MainContentViewController: UIViewController, PMainContent, UIScrollViewDelegate, WebVCDelegate {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    
    var presenter: MainPresenter?
    var behaviourController: Behaviour?
    var contentBelow: Bool = false
    var previewView: UIView?
    
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.presenter?.viewIsReady()
    }
    
    // MARK: Events
    
    
    @IBAction func didTap(_ backButton: UIButton) {
        self.hide()
    }
    
    // MARK: PMainContent
    
    func show(preview: Preview?, action: Action) {
        
        
        if (action.view()) != nil {
            self.contentBelow = true
        }
        
        if let previewView = preview?.display(), let preview = preview {
            self.previewView = previewView
            self.stackView.addArrangedSubview(previewView)
            self.behaviourController = PreviewInteractionController.previewInteractionController(scroll: self.scrollView, previewView: previewView, preview: preview, existContentBelow: self.contentBelow) {
                
                if !self.contentBelow {
                    action.executable()
                }
            }
        }
        
        if let viewAction = action.view() {
            if let webVC = viewAction as? WebVC {
                webVC.delegate = self
            }
            addChildViewController(viewAction)
            viewAction.didMove(toParentViewController: self)
            self.stackView.addArrangedSubview(viewAction.view)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.behaviourController?.scrollViewDidEndScrollingAnimation(scrollView)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.updateBackButton(scrollView: scrollView, isWebView: false)
        self.behaviourController?.scrollViewDidScroll(scrollView)
    }
    
    func webViewDidScroll(_ scrollView: UIScrollView) {
        
        self.updateBackButton(scrollView: scrollView, isWebView: true)
    }
    
    func updateBackButton(scrollView: UIScrollView, isWebView: Bool) {
        
        if self.lastContentOffset < scrollView.contentOffset.y { // MOVE DOWN
            backButton.alpha = backButton.alpha > 0 ? backButton.alpha - 0.1 : 0
        } else { // MOVE UP
            backButton.alpha = backButton.alpha < 1 ? backButton.alpha + 0.1 : 1
        }
        
        if scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height { // BOTOM Exeeded
            backButton.alpha = 0
        }
        
        if !isWebView {
            if let previewView = self.previewView, previewView.superview != nil {
                if scrollView.contentOffset.y <= previewView.frame.size.height { // TOP Preview
                    backButton.alpha = 1
                }
            }
        }
        
        if scrollView.contentOffset.y <= 0 { // TOP
            backButton.alpha = 1
        }
        
        self.lastContentOffset = scrollView.contentOffset.y
        self.behaviourController?.scrollViewDidScroll(scrollView)
    }
}
