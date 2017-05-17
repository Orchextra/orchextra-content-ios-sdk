//
//  PreviewView.swift
//  OCM
//
//  Created by Sergio López on 7/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewImageTextView: UIView, PreviewView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradingImageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    
    weak var delegate: PreviewViewDelegate?
    var behaviour: Behaviour?
    var tapButton: UIButton?
    
    var initialLabelPosition = CGPoint.zero
    var initialImagePosition = CGPoint.zero

    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewImageTextView? {
        guard let previewView = Bundle.OCMBundle().loadNibNamed("PreviewImageTextView", owner: self, options: nil)?.first as? PreviewImageTextView else { return PreviewImageTextView() }
        return previewView
    }
    
    func load(preview: PreviewImageText) {
        
        self.setupTitle(title: preview.text)
        self.gradingImageView.image = self.gradingImage(forPreview: preview)
        
        if let urlString = preview.imageUrl {
            let height: Int = Int(self.imageView.bounds.size.height)
            let width: Int = Int(self.imageView.bounds.size.width)
            let scaleFactor: Int = Int(UIScreen.main.scale)
            let urlSizeComposserWrapper = UrlSizedComposserWrapper(
                urlString: urlString,
                width: width,
                height:height,
                scaleFactor: scaleFactor
            )
            
            let urlAddptedToSize = urlSizeComposserWrapper.urlCompossed
            self.imageView.imageFromURL(urlString: urlAddptedToSize, placeholder: Config.placeholder)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
    }
    
    func addTapButton() {
        if self.behaviour is Tap {
            self.tapButton = UIButton(type: .custom)
            self.tapButton?.backgroundColor = .clear
            self.tapButton?.addTarget(self, action: #selector(didTapPreviewView), for: .touchUpInside)
            if let tapButton = self.tapButton {
                self.addSubviewWithAutolayout(tapButton)
            }
        }
    }
    
    func imagePreview() -> UIImageView? {
        return self.imageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.alpha = 0
    }
    
    func previewDidAppear() {
        self.animate(willAppear: true)
        addTapButton()
    }

    func previewDidScroll(scroll: UIScrollView) {
        self.titleLabel.center = CGPoint(x: self.initialLabelPosition.x, y: self.initialLabelPosition.y - (scroll.contentOffset.y / 4))
        if scroll.contentOffset.y < 0 {
            self.imageContainer.center = CGPoint(x: self.initialImagePosition.x, y: self.initialImagePosition.y + scroll.contentOffset.y)
            self.imageView.alpha = 1 + (scroll.contentOffset.y / 350.0)
        } else {
            self.imageContainer.center = self.initialImagePosition
        }
        
        if self.behaviour is Swipe {
            self.behaviour?.performAction(with: scroll)
        }
    }
    
    func previewWillDissapear() {
        self.animate(willAppear: false)
    }
    
    func show() -> UIView {
        return self
    }

    // MARK: - UI Setup
    
    func setupTitle(title: String?) {
        
        guard let unwrappedTitle = title else {
            self.titleLabel.text = nil
            return
        }
        self.titleLabel.html = unwrappedTitle
        self.titleLabel.textAlignment = .right
        let attributedString = NSMutableAttributedString(string: unwrappedTitle)
        attributedString.addAttribute(NSKernAttributeName, value: 2.0, range: NSRange(location: 0, length: attributedString.length - 1))
        self.titleLabel.attributedText = attributedString
    }

    // MARK: - Actions
    
    @IBAction func didTap(_ share: UIButton) {
        self.delegate?.previewViewDidSelectShareButton()
    }
    
    @objc func didTapPreviewView(_ button: UIButton) {
        if self.behaviour is Tap {
            self.behaviour?.performAction(with: button)
        }
    }
    
    // MARK: - Convenience Methods

    private func gradingImage(forPreview preview: PreviewImageText) -> UIImage? {
        let thereIsContent = thereIsContentBelow(preview: preview)
        let hasTitle = preview.text != nil && preview.text?.isEmpty == false
        if hasTitle {
            return UIImage.OCM.previewGrading
        } else if thereIsContent {
            return UIImage.OCM.previewSmallGrading
        } else {
            return nil
        }
    }
    
    private func thereIsContentBelow(preview: Preview) -> Bool {
        return preview.behaviour != nil
    }
    
    private func animate(willAppear: Bool) {
        
        let titleInitialTransform = willAppear ? CGAffineTransform(translationX: 0, y: -20) : CGAffineTransform.identity
        let titleFinalTransform = willAppear ? CGAffineTransform.identity : CGAffineTransform(translationX: 0, y: -20)
        let alpha = CGFloat(willAppear ? 1.0 : 0.0)
        let labelPosition = willAppear ? self.titleLabel.center : CGPoint.zero
        let imagePosition = willAppear ? self.imageContainer.center : CGPoint.zero
        
        UIView.animate(withDuration: 0.5, animations: {
            self.gradingImageView.alpha = alpha
        })
        
        self.titleLabel.transform = titleInitialTransform
        
        UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseOut, animations: {
            self.titleLabel.transform = titleFinalTransform
            self.titleLabel.alpha = alpha
        })
        self.initialLabelPosition = labelPosition
        self.initialImagePosition = imagePosition
    }
}
