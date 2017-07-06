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
    fileprivate var titleLabel: MarginLabel?
    var isVisible: Bool = false

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
    
    func setup() {
        let alertBanner = MarginLabel(
            frame: CGRect(
                origin: CGPoint(
                    x: 0,
                    y: -self.height()
                ),
                size: self.size()
            )
        )
        
        alertBanner.text = self.message
        alertBanner.textColor = .white
        alertBanner.backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        alertBanner.font = UIFont(name: "Gotham Book", size: 14)
        alertBanner.textAlignment = .center
        alertBanner.numberOfLines = 2
        
        self.addSubview(alertBanner)
        self.titleLabel = alertBanner
    }
    
    // MARK: - Public methods
    
    func show(in containerView: UIView, hideIn: TimeInterval = 0) {
        self.isVisible = true
        containerView.addSubview(self)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.titleLabel?.frame = CGRect(origin: .zero, size: self.size())
        }) { (_) in
            if hideIn != 0 {
                UIView.animate(withDuration: 0.5,
                               delay: hideIn,
                               options: .curveEaseInOut,
                               animations: {
                                self.titleLabel?.frame = CGRect(origin: CGPoint(x: 0, y: -self.height()), size: self.size())
                }) { (_) in
                    self.isVisible = false
                    self.removeFromSuperview()
                }
            }
        }
    }
}

private class MarginLabel: UILabel {
    
    let margin = CGFloat(20)
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: self.margin, bottom: 0, right: self.margin)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
