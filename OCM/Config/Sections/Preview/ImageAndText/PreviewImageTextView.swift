//
//  PreviewView.swift
//  OCM
//
//  Created by Sergio López on 7/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewImageTextView: UIView, PreviewView, Refreshable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var grandientView: GradientView!
    @IBOutlet weak var imageContainer: UIView!
    
    weak var delegate: PreviewViewDelegate?
    var behaviour: Behaviour?
    var tapButton: UIButton?
    var viewDataStatus: ViewDataStatus = .notLoaded
    private let refreshManager = RefreshManager.shared
    
    var initialLabelPosition = CGPoint.zero
    var initialImagePosition = CGPoint.zero
    
    // MARK: - PUBLIC
    
    deinit {
        self.refreshManager.unregisterForNetworkChanges(self)
    }
    
    class func instantiate() -> PreviewImageTextView? {
        guard let previewView = Bundle.OCMBundle().loadNibNamed("PreviewImageTextView", owner: self, options: nil)?.first as? PreviewImageTextView else { return PreviewImageTextView() }
        return previewView
    }
    
    func load(preview: PreviewImageText) {
        self.refreshManager.registerForNetworkChanges(self)
        self.setupTitle(title: preview.text)
        self.grandientView.gradientLayer?.colors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor]
        self.grandientView.gradientLayer?.gradient = GradientPoint.topBottom.draw()
        // self.gradingImageView.image = self.gradingImage(forPreview: preview)
        
        if let urlString = preview.imageUrl {
            self.imageView.url = urlString
            self.imageView.image = Config.styles.placeholderImage
            ImageDownloadManager.shared.downloadImage(with: urlString) { image, _  in
                if let image = image {
                    self.viewDataStatus = .loaded
                    self.imageView.image = image
                }
            }
        }
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
        self.titleLabel.adjustFontSizeForLargestWord()
    }
    
    func previewDidScroll(scroll: UIScrollView) {
        self.titleLabel.center = CGPoint(x: self.initialLabelPosition.x, y: self.initialLabelPosition.y - (scroll.contentOffset.y / 4))
        if scroll.contentOffset.y < 0 {
            self.imageContainer.center = CGPoint(x: self.initialImagePosition.x, y: self.initialImagePosition.y + (scroll.contentOffset.y / 2))
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
    
    // MARK: - Refreshable
    
    func refresh() {
        if let urlString = self.imageView.url {
            ImageDownloadManager.shared.downloadImage(with: urlString, in: self.imageView, placeholder: Config.styles.placeholderImage)
        }
    }
    
    // MARK: - UI Setup
    
    func setupTitle(title: String?) {
        guard let unwrappedTitle = title else {
            self.titleLabel.text = nil
            return
        }
        self.titleLabel.text = unwrappedTitle
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
        
        self.titleLabel.transform = titleInitialTransform
        
        UIView.animate(withDuration: 0.35, delay: 0.2, options: .curveEaseOut, animations: {
            self.titleLabel.transform = titleFinalTransform
            self.titleLabel.alpha = alpha
        })
        self.initialLabelPosition = labelPosition
        self.initialImagePosition = imagePosition
    }
}
