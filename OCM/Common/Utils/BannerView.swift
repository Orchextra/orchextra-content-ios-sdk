//
//  BannerView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 16/05/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class BannerView: UIView {

    var message: String?
    var titleLabel: UILabel?

    // MARK: - Initalizers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Custom initializer
    
    init(frame: CGRect, message: String) {
        super.init(frame: frame)
        self.message = message
        setup()
    }
    
    // MARK: - Private methods
    
    private func setup() {
        let alertBanner = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: -(self.height())), size: self.size()))
        
        alertBanner.text = self.message
        alertBanner.textColor = .white
        alertBanner.adjustsFontSizeToFitWidth = true
        alertBanner.backgroundColor = UIColor(white: 1.0, alpha: 0.33)
        alertBanner.textAlignment = .center
        
        self.addSubview(alertBanner)
        self.titleLabel = alertBanner
    }
    
    // MARK: - Public methods
    
    func show(in containerView: UIView) {
    
        containerView.addSubview(self)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.titleLabel?.frame = CGRect(origin: .zero, size: self.size())
        }) { (_) in
            UIView.animate(withDuration: 0.5,
                                delay: 0.5,
                                options: .curveEaseInOut,
                                animations: {
                                    self.titleLabel?.frame = CGRect(origin: CGPoint(x: 0, y: -(self.height())), size: self.size())
            }) { (_) in
                self.removeFromSuperview()
            }
        }
    }
}
