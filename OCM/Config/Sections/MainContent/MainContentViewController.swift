//
//  MainContentViewController.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

enum MainContentViewType {
    case preview
    case content
}

class MainContentViewController: OrchextraViewController, MainContentUI {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var headerView: MainContentHeaderView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    var presenter: MainPresenterInput?
    var viewModel: MainContentViewModel?
    var currentlyViewing: MainContentViewType = .preview
    var lastContentOffset: CGFloat = 0
    
    weak var previewView: PreviewView?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        self.presenter?.viewIsReady()

        // Add a gesture to dimiss the view
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didTapOnBackButton))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
        self.headerView.delegate = self
        self.headerView.initHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.currentlyViewing == .preview {
            self.previewView?.previewDidAppear()
            self.previewView?.behaviour?.previewDidAppear()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.currentlyViewing == .preview {
            self.previewView?.previewWillDissapear()
        }
    }
    
    // MARK: - OrchextraViewController overriden methods

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: MainContentUI
    
    func show(_ viewModel: MainContentViewModel) {
        
        self.viewModel = viewModel
        self.headerView.viewModel = MainContentHeaderViewModel(backButtonIcon: viewModel.backButtonIcon)
        self.headerView.initNavigationTitle(viewModel.title)
        self.headerView.initShareButton(visible: (self.viewModel?.shareInfo == nil))
        if #available(iOS 11.0, *) { self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never } // Hotfix fot iOS 11
        
        // Add preview
        if let preview = viewModel.preview, let previewView = preview.display() {
            if #available(iOS 11.0, *) { self.scrollView.bounces = false } // Hotfix fot iOS 11
            self.previewView = previewView
            self.previewView?.delegate = self
            self.previewView?.behaviour = PreviewBehaviourFactory.behaviour(with: self.scrollView, previewView: previewView.show(), preview: preview, content: viewModel.content)
            self.currentlyViewing = .preview
            self.presenter?.contentPreviewDidLoad()
            self.stackView.addArrangedSubview(previewView.show())
        } else {
            self.currentlyViewing = .content
            self.presenter?.contentDidLoad()
        }
        self.view.layoutIfNeeded()
        
        // Add content component
        if let componentViewController = viewModel.content {
            addChildViewController(componentViewController)
            componentViewController.didMove(toParentViewController: self)
            self.addConstraintsToComponentView()
            self.stackView.addArrangedSubview(componentViewController.view)
        }
    }
    
    func innerScrollViewDidScroll(_ scrollView: UIScrollView) {
        self.previewView?.previewDidScroll(scroll: scrollView)
    }
    
    func showBannerAlert(_ message: String) {
        guard let banner = self.bannerView, banner.isVisible else {
            self.bannerView = BannerView(frame: CGRect(origin: CGPoint(x: 0, y: 80), size: CGSize(width: self.scrollView.width(), height: 50)), message: message)
            self.bannerView?.show(in: self.scrollView, hideIn: 1.5)
            return
        }
    }
    
    // MARK: - Private
    
    fileprivate func rearrangeViewForChangesOn(scrollView currentScroll: UIScrollView, isContentOwnScroll: Bool) {
        if let previewView = self.previewView?.show(), previewView.superview != nil {
            if !isContentOwnScroll,
                previewView.superview != nil,
                currentScroll.contentOffset.y >= previewView.frame.size.height, // Content Top & Preview Bottom
                !self.headerView.isHeaderVisible() {
                self.headerView.setupHeader(isAppearing: true)
            }
            if currentScroll.contentOffset.y <= 0, // Top
                self.headerView.isHeaderVisible() {
                self.headerView.setupHeader(isAppearing: false)
            }
            if currentScroll.contentOffset.y >= currentScroll.contentSize.height - previewView.frame.size.height, // Bottom
                !self.headerView.isHeaderVisible() {
                self.headerView.setupHeader(isAppearing: true)
            }
        } else {
            if currentScroll.contentOffset.y <= 0, // Top
                self.headerView.isHeaderVisible() {
                self.headerView.setupHeader(isAppearing: true)
            }
        }
    }
        
    fileprivate func addConstraintsToComponentView() {
        guard let viewModel = self.viewModel, let componentView = viewModel.content?.view  else { return }
        
        if viewModel.contentType == .actionWebview {
            componentView.addConstraint(NSLayoutConstraint(
                item: componentView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: self.view.height() - (self.headerView.isHeaderVisible() ? self.headerView.height() : 0)
            ))
        } else {
            componentView.addConstraint(NSLayoutConstraint(
                item: componentView,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: self.view.height()
            ))
        }
    }
    
    fileprivate func shareItems(shareInfo: ShareInfo) -> [Any] {
        var itemsToShare: [Any] = []
        if let text = shareInfo.text {
            itemsToShare.append(text)
        }
        if let urlString = shareInfo.url, let url = URL(string: urlString) {
            itemsToShare.append(url)
        }
        return itemsToShare
    }
}

// MARK: - UIScrollViewDelegate

extension MainContentViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.rearrangeViewForChangesOn(scrollView: scrollView, isContentOwnScroll: false)
        self.previewView?.previewDidScroll(scroll: scrollView)
        // Check if changed from preview to content
        if let preview = self.previewView as? UIView, self.viewModel?.content != nil {
            if scrollView.contentOffset.y == 0 && self.currentlyViewing == .content {
                self.currentlyViewing = .preview
                self.presenter?.contentPreviewDidLoad()
            } else if scrollView.contentOffset.y >= preview.frame.size.height && self.currentlyViewing == .preview {
                self.currentlyViewing = .content
                self.presenter?.contentDidLoad()
            } else if scrollView.contentOffset.y >= scrollView.contentSize.height - preview.frame.size.height && self.currentlyViewing == .preview {
                self.currentlyViewing = .content
                self.presenter?.contentDidLoad()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating && !scrollView.isDragging {
            self.presenter?.scrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.presenter?.scrollViewDidScroll(scrollView)
        }
    }
}

// MARK: - MainContentHeaderViewDelegate

extension MainContentViewController: MainContentHeaderViewDelegate {
    
    func didTapOnShareButton() {
        guard let shareInfo = self.viewModel?.shareInfo else { return }
        
        self.presenter?.userDidShare()
        let activityViewController = UIActivityViewController(activityItems: self.shareItems(shareInfo: shareInfo), applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
    @objc func didTapOnBackButton() {
        self.presenter?.removeComponent()
        self.hide()
    }
    
    func updateTopConstraint(constant: CGFloat) {
        self.stackViewTopConstraint.constant = constant
    }
    
    func isPreviewDisplayed() -> Bool {
        return self.previewView != nil
    }

    func isContentFromScrollLongEnough() -> Bool {
        if let previewHeight = self.previewView?.show().height() {
            return self.scrollView.contentSize.height - previewHeight <  previewHeight
        } else {
            return false
        }
    }
    
    func layoutScroll() {
        self.scrollView.layoutIfNeeded()
    }
}

// MARK: - PreviewViewDelegate

extension MainContentViewController: PreviewViewDelegate {
    
    func previewViewDidPerformBehaviourAction() {
        guard self.viewModel?.content != nil else { return }
        self.presenter?.performAction()
    }
}

// MARK: - ImageTransitionZoomable

extension MainContentViewController: ImageTransitionZoomable {
    
    func createTransitionImageView() -> UIImageView {
        var imageView: UIImageView
        if let imagePreview = self.previewView?.imagePreview()?.image {
            imageView = UIImageView(image: imagePreview)
        } else {
            imageView = UIImageView(frame: self.view.frame)
            if let image = Config.contentListStyles.transitionBackgroundImage {
                imageView.image = image
            } else {
                imageView.backgroundColor = Config.styles.secondaryColor
            }
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = self.imageView.frame
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
