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

class MainContentViewController: OrchextraViewController, MainContentUI, UIScrollViewDelegate, WebVCDelegate, PreviewViewDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerBackgroundImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    var presenter: MainPresenter?
    var contentBelow: Bool = false
    var contentFinished: Bool = false
    var currentlyViewing: MainContentViewType = .preview
    var lastContentOffset: CGFloat = 0
    var action: Action?
    
    weak var previewView: PreviewView?
    weak var viewAction: OrchextraViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView?.previewWillDissapear()
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
        self.previewView?.previewDidAppear()
        self.previewView?.behaviour?.previewDidAppear()
        self.setupHeader(isAppearing: self.previewView == nil, animated: self.previewView != nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Events
    
    @IBAction func didTap(share: UIButton) {
        self.presenter?.userDidShare()
    }
    
    @IBAction func didTap(backButton: UIButton) {
        self.viewAction?.removeFromParentViewController()
        self.hide()
    }
    
    // MARK: MainContent
    
    func show(name: String?, preview: Preview?, action: Action) {
        
        self.initNavigationTitle(name)
        
        if (action.view()) != nil {
            self.contentBelow = true
        }
        
        self.action = action
        self.viewAction = action.view()
        
        if let previewView = preview?.display(), let preview = preview {
            self.previewView = previewView
            self.previewView?.delegate = self
            self.previewView?.behaviour = PreviewBehaviourFactory.behaviour(with: self.scrollView, previewView: previewView.show(), preview: preview, content: viewAction)
            self.currentlyViewing = .preview
            self.previewLoaded()
            self.stackView.addArrangedSubview(previewView.show())
        } else {
            self.currentlyViewing = .content
            self.contentLoaded()
        }
        
        if let viewAction = self.viewAction {
            
            if let webVC = viewAction as? WebVC {
                webVC.delegate = self
            }
            
            addChildViewController(viewAction)
            viewAction.didMove(toParentViewController: self)
            // Set the action view to have at least the view height
            viewAction.view.addConstraint(NSLayoutConstraint(
                item: viewAction.view,
                attribute: .height,
                relatedBy: .greaterThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: self.stackView.height()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.rearrangeViewForChangesOn(scrollView: scrollView, isContentOwnScroll: false)
        self.previewView?.previewDidScroll(scroll: scrollView)
        // Check if changed from preview to content
        if let preview = self.previewView as? UIView, self.viewAction != nil {
            if scrollView.contentOffset.y == 0 {
                if self.currentlyViewing == .content {
                    self.currentlyViewing = .preview
                    // Notify that user is in preview
                    self.previewLoaded()
                }
            } else if scrollView.contentOffset.y >= preview.frame.size.height && self.currentlyViewing == .preview {
                self.currentlyViewing = .content
                // Notify that user is in content
                self.contentLoaded()
            } else if scrollView.contentOffset.y >= scrollView.contentSize.height - preview.frame.size.height && self.currentlyViewing == .preview {
                self.currentlyViewing = .content
                // Notify that user is in content (content after preview on scrollview is smaller than the screen)
                self.contentLoaded()
            }
        }
        // To check if scroll did end
        if !self.contentFinished && (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            self.contentFinished = true
            self.presenter?.userDidFinishContent()
        }
    }
    
    // MARK: - WebVCDelegate
    
    func webViewDidScroll(_ webViewScroll: UIScrollView) {
        self.rearrangeViewForChangesOn(scrollView: webViewScroll, isContentOwnScroll: true)
        self.previewView?.previewDidScroll(scroll: webViewScroll)
    }
    
    // MARK: - PreviewDelegate
    
    func previewViewDidSelectShareButton() {
        self.presenter?.userDidShare()
    }
    
    func previewViewDidPerformBehaviourAction() {
        if !self.contentBelow {
             self.action?.executable()
        }
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
            if currentScroll.contentOffset.y <= 0 { // Top
                if self.headerBackgroundImageView.alpha != 0 {
                    self.setupHeader(isAppearing: false)
                }
            }
            if currentScroll.contentOffset.y >= currentScroll.contentSize.height - previewView.frame.size.height { // Bottom
                if self.headerBackgroundImageView.alpha == 0 {
                    self.setupHeader(isAppearing: true)
                }
            }
        } else {
            if currentScroll.contentOffset.y <= 0 { // Top
                if self.headerBackgroundImageView.alpha != 0 {
                    self.setupHeader(isAppearing: true)
                }
            }
        }
        
    }
    
    private func initNavigationTitle(_ title: String?) {
        self.headerTitleLabel.textColor = Config.contentNavigationBarStyles.barTintColor
        self.headerTitleLabel.text = title?.capitalized
        self.headerTitleLabel.adjustsFontSizeToFitWidth = true
        self.headerTitleLabel.minimumScaleFactor = 12.0 / UIFont.labelFontSize
    }
    
    private func setupNavigationTitle(isAppearing: Bool, animated: Bool) {
        self.headerTitleLabel.isHidden = !isAppearing
        let alpha: CGFloat = isAppearing ? 1.0 : 0.0
        if animated {
            UIView.animate(withDuration: 0.1,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: {
                            self.headerTitleLabel.alpha = alpha
            },
                           completion: nil)
        } else {
            self.headerTitleLabel.alpha = alpha
        }
    }
    
    private func initHeader() {
        
        self.shareButton.alpha = 0.0
        self.backButton.alpha = 0.0
        self.headerBackgroundImageView.alpha = 0
        self.headerBackgroundImageView.frame = CGRect(x: 0, y: 0, width: self.headerView.width(), height: 0)
        
        self.shareButton.layer.masksToBounds = true
        self.shareButton.layer.cornerRadius = self.shareButton.width() / 2
        self.backButton.layer.masksToBounds = true
        self.backButton.layer.cornerRadius = self.backButton.width() / 2
        
        self.shareButton.setImage(UIImage.OCM.shareButtonIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.shareButton.tintColor = Config.contentNavigationBarStyles.buttonTintColor
        self.backButton.setImage(UIImage.OCM.backButtonIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.backButton.tintColor = Config.contentNavigationBarStyles.buttonTintColor
        
        self.headerTitleLabel.isHidden = true
        self.headerTitleLabel.alpha = 0.0
        
        if Config.contentNavigationBarStyles.type == .navigationBar {
            // Set header
            if let navigationBarBackgroundImage = Config.contentNavigationBarStyles.barBackgroundImage {
                self.headerBackgroundImageView.image = navigationBarBackgroundImage
                self.headerBackgroundImageView.contentMode = .scaleToFill
            } else {
                self.headerBackgroundImageView.backgroundColor = Config.contentNavigationBarStyles.barBackgroundColor            }
            // Set buttons
            self.shareButton.setBackgroundImage(Config.contentNavigationBarStyles.buttonBackgroundImage, for: .normal)
            self.backButton.setBackgroundImage(Config.contentNavigationBarStyles.buttonBackgroundImage, for: .normal)
        } else {
            // Set header
            self.headerBackgroundImageView.backgroundColor = Config.contentNavigationBarStyles.barBackgroundColor
            // Set buttons
            self.shareButton.backgroundColor = Config.contentNavigationBarStyles.buttonBackgroundColor
            self.backButton.backgroundColor = Config.contentNavigationBarStyles.buttonBackgroundColor
        }
    }
    
    private func setupHeader(isAppearing: Bool, animated: Bool = true) {
        
        self.shareButton.alpha = 1.0
        self.backButton.alpha = 1.0
        
        guard Config.contentNavigationBarStyles.type == .navigationBar else {
            return
        }
        
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
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.headerBackgroundImageView.frame = frame
                            self.headerBackgroundImageView.alpha = headerBackgroundAlpha
                            if Config.contentNavigationBarStyles.showTitle && !isAppearing {
                                self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
                            }
                            self.scrollView.layoutIfNeeded()
            },
                           completion: { (_) in
                            if Config.contentNavigationBarStyles.showTitle && isAppearing {
                                self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
                            }
            })
        } else {
            self.headerBackgroundImageView.frame = frame
            self.headerBackgroundImageView.alpha = headerBackgroundAlpha
            if Config.contentNavigationBarStyles.showTitle {
                self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
            }
            self.scrollView.layoutIfNeeded()
        }
    }
    
    private func previewLoaded() {
        if let actionIdentifier = self.action?.identifier {
            OCM.shared.analytics?.track(with: [
                AnalyticConstants.kAction: AnalyticConstants.kPreview,
                AnalyticConstants.kValue: actionIdentifier,
                AnalyticConstants.kContentType: AnalyticConstants.kPreview
            ])
        }
    }
    
    private func contentLoaded() {
        if let actionIdentifier = self.action?.identifier {
            OCM.shared.analytics?.track(with: [
                AnalyticConstants.kAction: AnalyticConstants.kContent,
                AnalyticConstants.kValue: actionIdentifier,
                AnalyticConstants.kContentType: Content.contentType(of: actionIdentifier) ?? ""
            ])
        }
    }
    
}

extension MainContentViewController: ImageTransitionZoomable {
    
    // MARK: - ImageTransitionZoomable
    
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
        
        imageView.contentMode = self.imageView.contentMode
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
