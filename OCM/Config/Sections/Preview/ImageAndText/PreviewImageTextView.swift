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
    
    var initialLabelPosition = CGPoint.zero
    var initialSharePosition = CGPoint.zero
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
    
    func imagePreview() -> UIImageView? {
        return self.imageView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.alpha = 0
    }
    
    func previewDidAppear() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.gradingImageView.alpha = 1
        })
        
        self.titleLabel.transform = CGAffineTransform(translationX: 0, y: -20)

        UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseOut, animations: {
            self.titleLabel.transform = CGAffineTransform.identity
            self.titleLabel.alpha = 1
        })
        self.initialLabelPosition = self.titleLabel.center
        self.initialImagePosition = self.imageContainer.center
    }

    func previewDidScroll(scroll: UIScrollView) {
        self.titleLabel.center = CGPoint(x: self.initialLabelPosition.x, y: self.initialLabelPosition.y - (scroll.contentOffset.y / 4))
        if scroll.contentOffset.y < 0 {
            self.imageContainer.center = CGPoint(x: self.initialImagePosition.x, y: self.initialImagePosition.y + scroll.contentOffset.y)
            self.imageView.alpha = 1 + (scroll.contentOffset.y / 350.0)
        } else {
            self.imageContainer.center = self.initialImagePosition
        }

    }
    
    func show() -> UIView {
        return self
    }

    // MARK: - UI Setup
    
    func setupTitle(title: String?) {
        
        guard let unwrappedTitle = title else {
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
    
    // MARK: - Convenience Methods

    func gradingImage(forPreview preview: PreviewImageText) -> UIImage? {
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
    
    func thereIsContentBelow(preview: Preview) -> Bool {
        return preview.behaviour != nil
    }
}
