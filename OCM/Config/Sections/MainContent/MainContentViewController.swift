//
//  MainContentViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class MainContentViewController: OrchextraViewController, PMainContent, UIScrollViewDelegate,
WebVCDelegate, PreviewViewDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var presenter: MainPresenter?
    var behaviourController: Behaviour?
    var contentBelow: Bool = false
    
    var previewView: PreviewView?
    
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.presenter?.viewIsReady()
        self.configureShareButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.previewView?.viewDidAppear()
    }
    // MARK: Events
    
    @IBAction func didTap(share: UIButton) {
        self.share()
    }
    
    @IBAction func didTap(backButton: UIButton) {
        self.hide()
    }
    
    // MARK: PMainContent
    
    func show(preview: Preview?, action: Action) {
        
        if (action.view()) != nil {
            self.contentBelow = true
        }
        
        let viewAction = action.view()
        
        if let previewView = preview?.display(), let preview = preview {
            self.previewView = previewView
            previewView.delegate = self
            self.stackView.addArrangedSubview(previewView)
            self.behaviourController = PreviewInteractionController.previewInteractionController(scroll: self.scrollView, previewView: previewView, preview: preview, content: viewAction) {
                
                if !self.contentBelow {
                    action.executable()
                }
            }
        }
        
        if let viewAction = viewAction {
            
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
        self.updateFloatingButtons(scrollView: scrollView, isContentOwnScroll: false)
        self.behaviourController?.scrollViewDidScroll(scrollView)
        self.previewView?.previewDidScroll(scroll: scrollView)
    }
    
    // MARK: - WebVCDelegate
    
    func webViewDidScroll(_ webViewScroll: UIScrollView) {
        self.updateFloatingButtons(scrollView: webViewScroll, isContentOwnScroll: true)
        self.behaviourController?.scrollViewDidScroll(webViewScroll)
    }
    
    // MARK: - PreviewDelegate
    
    func previewViewDidSelectShareButton() {
        self.share()
    }
    
    // MARK: - PRIVATE
    
    private func updateFloatingButtons(scrollView currentScroll: UIScrollView, isContentOwnScroll: Bool) {
        
        var shareButtonAlpha = self.shareButton.alpha
        shareButtonAlpha = self.alphaAccordingToDirection(forButton: shareButton, scroll: currentScroll)
        self.backButton.alpha = self.alphaAccordingToDirection(forButton: backButton, scroll: currentScroll)
        
        if let previewView = self.previewView, previewView.superview != nil {
            
            if !isContentOwnScroll {
                if let previewView = self.previewView, previewView.superview != nil {
                    if currentScroll.contentOffset.y <= previewView.frame.size.height { // TOP Preview
                        backButton.alpha = 1
                    }
                    
                    if self.scrollView.contentOffset.y == previewView.frame.size.height {
                        shareButtonAlpha = 1
                    }
                }
                let offset =  1 - ((previewView.frame.size.height - self.scrollView.contentOffset.y) / 100)
                shareButtonAlpha = offset
            } else {
                if currentScroll.contentOffset.y < 0 { // TOP
                    shareButtonAlpha = 1
                }
            }
        }
        
        if currentScroll.contentOffset.y <= 0 { // TOP
            backButton.alpha = 1
        }
        
        self.shareButton.alpha = shareButtonAlpha
        
        self.lastContentOffset = currentScroll.contentOffset.y
    }
    
    func alphaAccordingToDirection(forButton button: UIButton, scroll: UIScrollView) -> CGFloat {
        
        let contentOffset =  self.lastContentOffset
        var alpha: CGFloat = 0
        
        if contentOffset < scroll.contentOffset.y { // MOVE DOWN
            alpha = backButton.alpha > 0 ? backButton.alpha - 0.1 : 0
        } else { // MOVE UP
            alpha = backButton.alpha < 1 ? backButton.alpha + 0.1 : 1
        }
        
        if scroll.contentOffset.y + scroll.frame.size.height >= scroll.contentSize.height { // BOTOM Exeeded
            alpha = 0
        }
        
        return alpha
    }
    
    func configureShareButton() {
        if let previewView = self.previewView, previewView.superview != nil {
            self.shareButton.alpha = 0
        } else {
            self.shareButton.alpha = 1
        }
    }
    
    func share() {
        let shareUrl = URL(string: "http://www.google.es")
        
        if let shareUrl = shareUrl {
            let activityViewController = UIActivityViewController(activityItems: [shareUrl], applicationActivities: nil)
            self.present(activityViewController, animated: true)
        }
    }
}
