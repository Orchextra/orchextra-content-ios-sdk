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
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imageContainer: UIView!
    
    weak var delegate: PreviewViewDelegate?
    
    var initialLabelPosition = CGPoint.zero
    var initialSharePosition = CGPoint.zero
    var initialImagePosition = CGPoint.zero

    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewImageTextView? {
        guard let previewView = Bundle.OCMBundle().loadNibNamed("PreviewImageTextView", owner: self, options: nil)?.first as? PreviewImageTextView else { return PreviewImageTextView() }
        return previewView
    }
    
    func load(preview: PreviewImageText) {
        self.titleLabel.html = preview.text
        self.titleLabel.textAlignment = .right
        self.shareButton.isHidden = ( preview.shareInfo == nil )
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
    
    func imagePreview() -> UIImageView? {
        return self.imageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.alpha = 0
        self.shareButton.alpha = 0
    }
    
    func previewDidAppear() {
        self.animate(willAppear: true)
    }

    func previewDidScroll(scroll: UIScrollView) {
        self.titleLabel.center = CGPoint(x: self.initialLabelPosition.x, y: self.initialLabelPosition.y - (scroll.contentOffset.y / 4))
        self.shareButton.center = CGPoint(x: self.initialSharePosition.x, y: self.initialSharePosition.y - (scroll.contentOffset.y / 4))
        if scroll.contentOffset.y < 0 {
            self.imageContainer.center = CGPoint(x: self.initialImagePosition.x, y: self.initialImagePosition.y + scroll.contentOffset.y)
            self.imageView.alpha = 1 + (scroll.contentOffset.y / 350.0)
        } else {
            self.imageContainer.center = self.initialImagePosition
        }

    }
    
    func previewWillDissapear() {
        self.animate(willAppear: false)
    }
    
    func show() -> UIView {
        return self
    }

    // MARK: - Actions
    
    @IBAction func didTap(_ share: UIButton) {
        self.delegate?.previewViewDidSelectShareButton()
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
        
        let shareInitialTransform = willAppear ? CGAffineTransform(scaleX: 0.3, y: 0.3) : CGAffineTransform.identity
        let shareFinalTransform = willAppear ? CGAffineTransform.identity : CGAffineTransform(scaleX: 0.3, y: 0.3)
        let titleInitialTransform = willAppear ? CGAffineTransform(translationX: 0, y: -20) : CGAffineTransform.identity
        let titleFinalTransform = willAppear ? CGAffineTransform.identity : CGAffineTransform(translationX: 0, y: -20)
        let alpha = CGFloat(willAppear ? 1.0 : 0.0)
        let labelPosition = willAppear ? self.titleLabel.center : CGPoint.zero
        let sharePosition = willAppear ? self.shareButton.center : CGPoint.zero
        let imagePosition = willAppear ? self.imageContainer.center : CGPoint.zero
        
        self.shareButton.transform = shareInitialTransform
        
        UIView.animate(withDuration: 0.5, animations: {
            self.gradingImageView.alpha = alpha
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.shareButton.transform = shareFinalTransform
            self.shareButton.alpha = alpha
        })
        
        self.titleLabel.transform = titleInitialTransform
        
        UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseOut, animations: {
            self.titleLabel.transform = titleFinalTransform
            self.titleLabel.alpha = alpha
        })
        self.initialLabelPosition = labelPosition
        self.initialSharePosition = sharePosition
        self.initialImagePosition = imagePosition
    }
}
