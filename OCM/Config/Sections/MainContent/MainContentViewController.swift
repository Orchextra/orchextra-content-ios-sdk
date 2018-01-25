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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBackgroundImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
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
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didTap(backButton:)))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
        self.initHeader()
        self.setupHeader(isAppearing: self.previewView == nil, animated: self.previewView != nil)
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
    
    // MARK: Events
    
    @IBAction func didTap(share: UIButton) {
        guard let shareInfo = self.viewModel?.shareInfo else { return }
        self.presenter?.userDidShare()
        var itemsToShare: [Any] = []
        if let text = shareInfo.text {
            itemsToShare.append(text)
        }
        if let urlString = shareInfo.url, let url = URL(string: urlString) {
            itemsToShare.append(url)
        }
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    
    @IBAction func didTap(backButton: UIButton) {
        self.presenter?.removeComponent()
        self.hide()
    }
    
    // MARK: MainContentUI
    
    func show(_ viewModel: MainContentViewModel) {
        
        self.viewModel = viewModel
        self.initNavigationTitle()
        self.shareButton.isHidden = (self.viewModel?.shareInfo == nil)
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
                self.headerBackgroundImageView.alpha == 0 {
                    self.setupHeader(isAppearing: true)
            }
            if currentScroll.contentOffset.y <= 0, // Top
                self.headerBackgroundImageView.alpha != 0 {
                self.setupHeader(isAppearing: false)
            }
            if currentScroll.contentOffset.y >= currentScroll.contentSize.height - previewView.frame.size.height, // Bottom
                self.headerBackgroundImageView.alpha == 0 {
                self.setupHeader(isAppearing: true)
            }
        } else {
            if currentScroll.contentOffset.y <= 0, // Top
                self.headerBackgroundImageView.alpha != 0 {
                self.setupHeader(isAppearing: true)
            }
        }
    }
    
    fileprivate func initNavigationTitle() {
        guard let title = self.viewModel?.title else { return }
        self.headerTitleLabel.textColor = Config.contentNavigationBarStyles.barTintColor
        self.headerTitleLabel.text = title.capitalized
        self.headerTitleLabel.adjustsFontSizeToFitWidth = true
        self.headerTitleLabel.minimumScaleFactor = 12.0 / UIFont.labelFontSize
    }
    
    fileprivate func setupNavigationTitle(isAppearing: Bool, animated: Bool) {
        guard  Config.contentNavigationBarStyles.showTitle else { return }
        self.headerTitleLabel.isHidden = !isAppearing
        let alpha: CGFloat = isAppearing ? 1.0 : 0.0
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                self.headerTitleLabel.alpha = alpha
            }, completion: nil)
        } else {
            self.headerTitleLabel.alpha = alpha
        }
    }
    
    fileprivate func initHeader() {
        
        if self.previewView != nil {
            self.headerBackgroundImageView.alpha = 0
            self.headerBackgroundImageView.frame = CGRect(x: 0, y: 0, width: self.headerView.width(), height: 0)
            self.headerTitleLabel.isHidden = true
            self.headerTitleLabel.alpha = 0.0

        } else {
            self.stackViewTopConstraint.constant = self.headerView.height()
        }
        
        // Set buttons
        self.initNavigationButton(button: self.shareButton, icon: UIImage.OCM.shareButtonIcon)
        if let backButtonIcon = self.viewModel?.backButtonIcon {
            self.initNavigationButton(button: self.backButton, icon: backButtonIcon)
        }
        if self.previewView == nil && self.viewModel?.contentType == .actionWebview {
            self.initNavigationButton(button: self.backButton, icon: self.viewModel?.backButtonIcon)
        } else {
            self.initNavigationButton(button: self.backButton, icon: self.viewModel?.backButtonIcon)
        }
        
        if Config.contentNavigationBarStyles.type == .navigationBar {
            // Set header
            if let navigationBarBackgroundImage = Config.contentNavigationBarStyles.barBackgroundImage {
                self.headerBackgroundImageView.image = navigationBarBackgroundImage
                self.headerBackgroundImageView.contentMode = .scaleToFill
            } else {
                self.headerBackgroundImageView.backgroundColor = Config.contentNavigationBarStyles.barBackgroundColor
            }
        } else {
            // Set header
            self.headerBackgroundImageView.backgroundColor = Config.contentNavigationBarStyles.barBackgroundColor
        }
    }
    
    fileprivate func setupHeader(isAppearing: Bool, animated: Bool = true) {
        
        self.shareButton.alpha = 1.0
        self.backButton.alpha = 1.0
        
        guard Config.contentNavigationBarStyles.type == .navigationBar else { return }
        
        let buttonBackgroundImage: UIImage? = isAppearing ? .none : Config.contentNavigationBarStyles.buttonBackgroundImage
        let buttonBackgroundColor: UIColor = isAppearing ? .clear : Config.contentNavigationBarStyles.buttonBackgroundColor
        let headerBackgroundAlpha = CGFloat(isAppearing ? 1: 0)
        let headerHeight = isAppearing ? self.headerView.height() : 0
        let frame = CGRect(x: 0, y: 0, width: self.headerView.width(), height: headerHeight)
        if let previewHeight = self.previewView?.show().height(), self.scrollView.contentSize.height - previewHeight <  previewHeight {
            // Content in scroll is not long enough
            self.stackViewTopConstraint.constant = 0
        } else {
            self.stackViewTopConstraint.constant = headerHeight
        }
        
        if Config.contentNavigationBarStyles.buttonBackgroundImage != nil {
            self.backButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
            self.shareButton.setBackgroundImage(buttonBackgroundImage, for: .normal)
        } else {
            self.backButton.backgroundColor = buttonBackgroundColor
            self.shareButton.backgroundColor = buttonBackgroundColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.headerBackgroundImageView.frame = frame
                self.headerBackgroundImageView.alpha = headerBackgroundAlpha
                if !isAppearing {
                    self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
                }
                self.scrollView.layoutIfNeeded()
            }, completion: { (_) in
                if headerBackgroundAlpha == 1 && self.viewModel?.contentType == .actionWebview {
                    self.backButton.setImage(self.viewModel?.backButtonIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    self.backButton.setImage(self.viewModel?.backButtonIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
                }
                if isAppearing {
                    self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
                }
            })
        } else {
            self.headerBackgroundImageView.frame = frame
            self.headerBackgroundImageView.alpha = headerBackgroundAlpha
            self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
            self.scrollView.layoutIfNeeded()
        }
    }
    
    fileprivate func initNavigationButton(button: UIButton, icon: UIImage?) {
        button.alpha = (self.previewView != nil) ? 0.0 : 1.0
        button.layer.masksToBounds = true
        button.layer.cornerRadius = self.shareButton.width() / 2
        button.setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = Config.contentNavigationBarStyles.buttonTintColor
        if Config.contentNavigationBarStyles.type == .navigationBar {
            button.setBackgroundImage(Config.contentNavigationBarStyles.buttonBackgroundImage, for: .normal)
        } else {
            button.backgroundColor = Config.contentNavigationBarStyles.buttonBackgroundColor
        }
    }
    
    fileprivate func isHeaderVisible() -> Bool {
        return self.headerBackgroundImageView.alpha != 0.0
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
                constant: self.view.height() - (self.isHeaderVisible() ? self.headerView.height() : 0)
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
