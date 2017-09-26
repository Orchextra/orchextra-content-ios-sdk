//
//  ErrorViewDefault.swift
//  OCM
//
//  Created by Judith Medina on 21/09/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

open class ErrorViewDefault: UIView, ErrorView {
    
    // MARK: - Public properties
    
    open var backgroundImage: UIImage?
    open var title: String?
    open var subtitle: String?
    open var buttonTitle: String?
    
    // MARk: - Private properties
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    
    var retryBlock: (() -> Void)?
    public func view() -> UIView {
        Bundle.OCMBundle().loadNibNamed("ErrorViewDefault", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = Config.styles.primaryColor
        retryButton.setTitle("RETRY", for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        
        backImage.image = backgroundImage
        
        if let titleText = title {
            self.titleLabel.text = titleText
        }
        
        if let subtitleText = subtitle {
            self.subtitleLabel.text = subtitleText
        }
        
        if let buttonTitle = buttonTitle {
             retryButton.setTitle(buttonTitle, for: .normal)
        }
        
        return self
    }
    
    public func set(retryBlock: @escaping () -> Void) {
        self.retryBlock = retryBlock
    }
    
    public func set(errorDescription: String) {
        
    }
    
    public func instantiate() -> UIView {
        Bundle.OCMBundle().loadNibNamed("ErrorViewDefault", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = Config.styles.primaryColor
        retryButton.setTitle("RETRY", for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        
        backImage.image = backgroundImage
        
        if let titleText = title {
            self.titleLabel.text = titleText
        }
        
        if let subtitleText = subtitle {
            self.subtitleLabel.text = subtitleText
        }
        
        if let buttonTitle = buttonTitle {
            retryButton.setTitle(buttonTitle, for: .normal)
        }
        
        return self
    }
    
    @objc func didTapRetry() {
        retryBlock?()
    }
}
