//
//  ImageActivityIndicator.swift
//  OCM
//
//  Created by José Estela on 14/12/17.
//  Copyright © 2017 Gigigo Mobile Services S.L. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ImageActivityIndicator: UIView {
    
    @IBInspectable
    var image: UIImage? {
        didSet {
            self.initializeView()
        }
    }
    
    @IBInspectable
    var visibleWhenStopped: Bool = true {
        didSet {
            self.initializeView()
        }
    }
    
    private var isAnimating = false
    private var imageView = UIImageView()
    
    // MARK: - View life cycle methods
    
    init(frame: CGRect, image: UIImage, tintColor: UIColor = UIColor.lightGray) {
        super.init(frame: frame)
        self.image = image
        self.tintColor = tintColor
        self.initializeView()
        self.hideIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeView()
        self.hideIfNeeded()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.initializeView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
        self.hideIfNeeded()
    }
    
    deinit {
        self.stopAnimating()
    }
    
    // MARK: - Public methods
    
    func startAnimating() {
        guard self.isAnimating == false else { return }
        self.isHidden = false
        self.isAnimating = true
        self.startRotating(imageView: self.imageView, duration: 1.0)
    }
    
    func stopAnimating() {
        guard self.isAnimating == true else { return }
        self.isAnimating = false
        if !self.visibleWhenStopped {
            self.isHidden = true
        }
    }
    
    // MARK: - Private Helpers
    
    private func startRotating(imageView: UIImageView, duration: Double) {
        UIView.animate(withDuration: duration/2, delay: 0.0, options: .curveLinear, animations: {
            imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        }, completion: { _ in
            UIView.animate(withDuration: duration/2, delay: 0.0, options: .curveLinear, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi*2))
            }, completion: { _ in
                if self.isAnimating {
                    self.startRotating(imageView: imageView, duration: duration)
                }
            })
        })
    }
    
    private func hideIfNeeded() {
        if !self.visibleWhenStopped && !self.isAnimating {
            self.isHidden = true
        }
    }
    
    private func initializeView() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        if self.image != nil {
            self.imageView = UIImageView(image: self.image)
            self.addSubview(self.imageView, settingAutoLayoutOptions: [
                .margin(to: self, top: 0, bottom: 0, left: 0, right: 0)
                ])
            if let image = self.imageView.image {
                let renderedImage = image.withRenderingMode(.alwaysTemplate)
                self.imageView.image = renderedImage
                self.imageView.tintColor = self.tintColor
            }
        }
    }
    
}
