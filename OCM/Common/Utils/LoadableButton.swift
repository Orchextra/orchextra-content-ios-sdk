//
//  LoadableButton.swift
//  OCM
//
//  Created by José Estela on 18/1/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit

class LoadableButton: AutoAjustableButton {
    
    // MARK: - Private attributes
    
    private var titleBeforeStartLoading: String?
    private var backgroundColorBeforeStartLoading: UIColor?
    private var activityIndicator: ImageActivityIndicator?
    
    // MARK: - Public methods
    
    func startLoading() {
        self.titleBeforeStartLoading = self.title(for: .normal)
        self.backgroundColorBeforeStartLoading = self.backgroundColor?.withAlphaComponent(1.0)
        self.setTitle(nil, for: .normal)
        self.isEnabled = false
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.1)
        self.activityIndicator = ImageActivityIndicator(frame: .zero, image: UIImage.OCM.loadingIcon ?? UIImage())
        self.activityIndicator?.visibleWhenStopped = false
        guard let activityIndicator = self.activityIndicator else { return }
        self.addSubview(activityIndicator, settingAutoLayoutOptions: [
            .centerX(to: self),
            .centerY(to: self)
        ])
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()
        self.isEnabled = true
        self.setTitle(self.titleBeforeStartLoading, for: .normal)
        self.backgroundColor = self.backgroundColorBeforeStartLoading
    }
}
