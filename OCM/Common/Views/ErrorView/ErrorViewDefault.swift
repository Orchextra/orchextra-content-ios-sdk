//
//  ErrorViewDefault.swift
//  OCM
//
//  Created by Judith Medina on 21/09/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class ErrorViewDefault: UIView, ErrorView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    
    var retryBlock: (() -> Void)?
    public func view() -> UIView {
        Bundle.OCMBundle().loadNibNamed("ErrorViewDefault", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .gray
        retryButton.setTitle("RETRY", for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return self
    }
    
    public func set(retryBlock: @escaping () -> Void) {
        self.retryBlock = retryBlock
    }
    
    public func set(errorDescription: String) {
        
    }
    
    static func instantiate() -> ErrorView {
        let errorView = ErrorViewDefault(frame: CGRect.zero)
        return errorView
    }
    
    @objc func didTapRetry() {
        retryBlock?()
    }
}
