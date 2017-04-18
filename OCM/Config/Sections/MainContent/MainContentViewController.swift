//
//  MainContentViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class MainContentViewController: ModalImageTransitionViewController, PMainContent, UIScrollViewDelegate,
WebVCDelegate, PreviewViewDelegate, ImageTransitionZoomable {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBackgroundImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    var presenter: MainPresenter?
    var behaviourController: Behaviour?
    var contentBelow: Bool = false
    var contentFinished: Bool = false
    
    var previewView: PreviewView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.presenter?.viewIsReady()
        // Add a gesture to dimiss the view
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didTap(backButton:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
        self.initHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.previewView?.viewDidAppear()
        self.behaviourController?.previewDidAppear()
        self.setupHeader(isAppearing: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Events
    
    @IBAction func didTap(share: UIButton) {
        self.presenter?.userDidShare()
    }
    
    @IBAction func didTap(backButton: UIButton) {
        self.hide()
    }
    
    // MARK: MainContent
    
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
            // Set the action view as least the view height
            viewAction.view.addConstraint(NSLayoutConstraint(
                item: viewAction.view,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: self.view.bounds.size.height
            ))
            self.stackView.addArrangedSubview(viewAction.view)
        }
    }
    
    func makeShareButtons(visible: Bool) {
        self.shareButton.isHidden = !visible
    }
    
    func share(_ info: ShareInfo) {

        var itemsToShare: [Any] = []
        
        if let text = info.text {
            itemsToShare.append(text)
        }
        
        if let urlString = info.url, let url = URL(string: urlString) {
            itemsToShare.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.behaviourController?.scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.rearrangeViewForChangesOn(scrollView: scrollView, isContentOwnScroll: false)
        self.behaviourController?.scrollViewDidScroll(scrollView)
        self.previewView?.previewDidScroll(scroll: scrollView)
        // To check if scroll did end
        if !self.contentFinished && (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            self.contentFinished = true
            self.presenter?.userDidFinishContent()
        }
    }
    
    // MARK: - WebVCDelegate
    
    func webViewDidScroll(_ webViewScroll: UIScrollView) {
        self.rearrangeViewForChangesOn(scrollView: webViewScroll, isContentOwnScroll: true)
        self.behaviourController?.scrollViewDidScroll(webViewScroll)
    }
    
    // MARK: - PreviewDelegate
    
    func previewViewDidSelectShareButton() {
        self.presenter?.userDidShare()
    }
    
    // MARK: - Private
    
    private func rearrangeViewForChangesOn(scrollView currentScroll: UIScrollView, isContentOwnScroll: Bool) {
        
        if let previewView = self.previewView?.show(), previewView.superview != nil {
            if !isContentOwnScroll {
                if previewView.superview != nil,
                    currentScroll.contentOffset.y >= previewView.frame.size.height { // Content Top & Preview Bottom
                    if self.headerBackgroundImageView.alpha == 0 {
                        self.setupHeader(isAppearing: true)
                    }
                }
            }
        }
        if currentScroll.contentOffset.y <= 0 { // Top
            if self.headerBackgroundImageView.alpha != 0 {
                self.setupHeader(isAppearing: false)
            }
        }
    }
    
    private func initHeader() {
        self.headerBackgroundImageView.alpha = 0
        self.headerBackgroundImageView.frame = CGRect(x: 0, y: 0, width: self.headerView.width(), height: 0)
        self.shareButton.alpha = 0
        self.backButton.alpha = 0
    }
    
    private func setupHeader(isAppearing: Bool) {
        let buttonBackgroundImage = isAppearing ? .none : UIImage.OCM.buttonSolidBackground
        let headerBackgroundAlpha = CGFloat(isAppearing ? 1: 0)
        let headerHeight = isAppearing ? self.headerView.height() : 0
        let frame = CGRect(x: 0, y: 0, width: self.headerView.width(), height: headerHeight)
        self.stackViewTopConstraint.constant = headerHeight

        self.backButton.alpha = 1.0
        self.shareButton.alpha = 1.0
        self.backButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
        self.shareButton.setBackgroundImage(buttonBackgroundImage, for: .normal)

        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.headerBackgroundImageView.frame = frame
                        self.headerBackgroundImageView.alpha = headerBackgroundAlpha
                        self.scrollView.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    // MARK: - ImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        
        var imageView: UIImageView
        if let imagePreview = self.previewView?.imagePreview()?.image {
            imageView = UIImageView(image: imagePreview)
        } else {
            imageView = UIImageView(frame: self.view.frame)
            imageView.image = UIImage.OCM.colorPreviewView
        }
        imageView.contentMode = self.imageView.contentMode
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = self.imageView!.frame
        return imageView
    }
    
    func presentationBefore() {
        self.imageView.isHidden = true
    }
    
    func presentationCompletion(completeTransition: Bool) {
        self.imageView.isHidden = false
    }
    
    func dismissalBeforeAction() {
        self.imageView.isHidden = true
    }
    
    func dismissalCompletionAction(completeTransition: Bool) {
        if !completeTransition {
            self.imageView.isHidden = false
        }
    }
}
