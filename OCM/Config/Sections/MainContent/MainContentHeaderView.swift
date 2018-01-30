//
//  MainContentHeaderView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 25/01/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit

struct MainContentHeaderViewModel {
    let backButtonIcon: UIImage?
}

protocol MainContentHeaderViewDelegate: class {
    func didTapOnShareButton()
    func didTapOnBackButton()
    func updateTopConstraint(constant: CGFloat)
    func layoutScroll()
    func isContentFromScrollLongEnough() -> Bool
    func isPreviewDisplayed() -> Bool
}

protocol MainContentHeaderViewProtocol: class {
    func initHeader()
    func initNavigationButton(button: UIButton, icon: UIImage?)
    func setupHeader(isAppearing: Bool, animated: Bool)
    func initNavigationTitle(_ title: String?)
    func setupNavigationTitle(isAppearing: Bool, animated: Bool)
    func initShareButton(visible: Bool)
    func isHeaderVisible() -> Bool
}

class MainContentHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var headerBackgroundImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
 
    weak var delegate: MainContentHeaderViewDelegate?
    var viewModel: MainContentHeaderViewModel?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        Bundle.OCMBundle().loadNibNamed("MainContentHeaderView", owner: self, options: nil)
        self.addSubview(contentView)
    }
    
    // MARK: - IBActions
    @IBAction func didTap(share: UIButton) {
        self.delegate?.didTapOnShareButton()
    }
    
    @IBAction func didTap(backButton: UIButton) {
        self.delegate?.didTapOnBackButton()
    }
}

// MARK: - MainContentHeaderViewProtocol

extension MainContentHeaderView: MainContentHeaderViewProtocol {

    func initHeader() {
        
        guard let delegate = self.delegate else { return }
        let isPreviewDisplayed = delegate.isPreviewDisplayed()
        if  isPreviewDisplayed {
            self.headerBackgroundImageView.alpha = 0
            self.headerBackgroundImageView.frame = CGRect(x: 0, y: 0, width: self.width(), height: 0)
            self.headerTitleLabel.isHidden = true
            self.headerTitleLabel.alpha = 0.0
        } else {
            delegate.updateTopConstraint(constant: self.height())
        }
        
        // Set buttons
        self.initNavigationButton(button: self.shareButton, icon: UIImage.OCM.shareButtonIcon)
        if let backButtonIcon = self.viewModel?.backButtonIcon {
            self.initNavigationButton(button: self.backButton, icon: backButtonIcon)
        }
        self.initNavigationButton(button: self.backButton, icon: self.viewModel?.backButtonIcon)
        
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
        
        self.setupHeader(isAppearing: !isPreviewDisplayed, animated: isPreviewDisplayed)
    }
    
    func initNavigationButton(button: UIButton, icon: UIImage?) {
        guard let delegate = self.delegate else { return }

        button.alpha = delegate.isPreviewDisplayed() ? 0.0 : 1.0
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
    
    func setupHeader(isAppearing: Bool, animated: Bool = true) {
        
        guard let delegate = self.delegate else { return }
        
        self.shareButton.alpha = 1.0
        self.backButton.alpha = 1.0
        
        guard Config.contentNavigationBarStyles.type == .navigationBar else { return }
        
        let buttonBackgroundImage: UIImage? = isAppearing ? .none : Config.contentNavigationBarStyles.buttonBackgroundImage
        let buttonBackgroundColor: UIColor = isAppearing ? .clear : Config.contentNavigationBarStyles.buttonBackgroundColor
        let headerBackgroundAlpha = CGFloat(isAppearing ? 1: 0)
        let headerHeight = isAppearing ? self.height() : 0
        let frame = CGRect(x: 0, y: 0, width: self.width(), height: headerHeight)
        if delegate.isContentFromScrollLongEnough() {
            // Content in scroll is not long enough
            delegate.updateTopConstraint(constant: 0)
        } else {
            delegate.updateTopConstraint(constant: headerHeight)
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
                delegate.layoutScroll()
            }, completion: { (_) in
                self.backButton.setImage(self.viewModel?.backButtonIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
                if isAppearing {
                    self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
                }
            })
        } else {
            self.headerBackgroundImageView.frame = frame
            self.headerBackgroundImageView.alpha = headerBackgroundAlpha
            self.setupNavigationTitle(isAppearing: isAppearing, animated: animated)
            delegate.layoutScroll()
        }
    }
    
    func initNavigationTitle(_ title: String?) {
        guard let title = title else { return }
        self.headerTitleLabel.textColor = Config.contentNavigationBarStyles.barTintColor
        self.headerTitleLabel.text = title.capitalized
        self.headerTitleLabel.adjustsFontSizeToFitWidth = true
        self.headerTitleLabel.minimumScaleFactor = 12.0 / UIFont.labelFontSize
    }
    
    func setupNavigationTitle(isAppearing: Bool, animated: Bool) {
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
    
    func initShareButton(visible: Bool) {
        self.shareButton.isHidden = visible
    }
    
    func isHeaderVisible() -> Bool {
        return self.headerBackgroundImageView.alpha != 0.0
    }
}
