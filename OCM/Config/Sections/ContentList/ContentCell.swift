//
//  ContentCell.swift
//  OCM
//
//  Created by Alejandro Jiménez on 5/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ContentCell: UICollectionViewCell {
	
	fileprivate var content: Content!
	
	// MARK - UI Properties
    @IBOutlet weak var fakeMarginsView: UIView!
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak private var highlightedImageView: UIImageView!
    @IBOutlet weak var blockView: UIView!
    
    private let margin: CGFloat = 2
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        self.highlightedImageView.alpha = 0
        self.fakeMarginsView.backgroundColor =  Config.contentListStyles.cellMarginsColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use this instead of Autolayout to avoid a bug where the UImageView doens't have exactly the same size as the cell in some cases.
        self.imageContent.frame = self.bounds
        self.fakeMarginsView.frame = CGRect(x: self.imageContent.frame.origin.x - self.margin,
                                            y: self.imageContent.frame.origin.y - self.margin,
                                            width: self.imageContent.frame.size.width + self.margin,
                                            height: self.imageContent.frame.size.height + self.margin)
    }
	
    // MARK: - PUBLIC
    
	func bindContent(_ content: Content) {
		self.content = content
		guard let url = content.media.url else { return logWarn("No image url set") }
        guard let imageThumbnail = content.media.thumbnail else { return logWarn("No image thumbnail set") }
        
        let height: Int = Int(self.bounds.size.height)
        let width: Int = Int(self.bounds.size.width)
        let scaleFactor: Int = Int(UIScreen.main.scale)
        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: url,
            width: width,
            height:height,
            scaleFactor: scaleFactor
        )
        let urlAddptedToSize = urlSizeComposserWrapper.urlCompossed
        
        let thumbnail = Config.thumbnailEnabled ? (UIImage(data: imageThumbnail) ?? Config.styles.placeholderImage) : Config.styles.placeholderImage
        self.imageContent.imageFromURL(urlString: urlAddptedToSize, placeholder: thumbnail)
        self.blockView.isHidden = true
        self.blockView.removeSubviews()
        self.highlightedImageView.image = UIImage(named: "content_highlighted")

        if self.content.requiredAuth == "logged" && !Config.isLogged {
            
            if let blockedView = Config.blockedContentView {
                self.blockView.addSubviewWithAutolayout(blockedView.instantiate())
            } else {
                self.blockView.addSubviewWithAutolayout(BlockedViewDefault().instantiate())
            }
            self.blockView.isHidden = false
        }
	}
    
    func highlighted(_ highlighted: Bool) {
        self.highlightedImageView.alpha = highlighted ? 0.3 : 0
    }
}

class BlockedViewDefault: StatusView {
    func instantiate() -> UIView {
        let blockedView = UIView(frame: CGRect.zero)
        blockedView.addSubviewWithAutolayout(UIImageView(image: UIImage(named: "content_highlighted")))
        
        let imageLocker = UIImageView(image: UIImage(named: "wOAH_locker"))
        imageLocker.translatesAutoresizingMaskIntoConstraints = false
        imageLocker.center = blockedView.center
        blockedView.addSubview(imageLocker)
        blockedView.alpha = 0.75
        addConstraintsIcon(icon: imageLocker, view: blockedView)
        
        return blockedView
    }
    
    func addConstraintsIcon(icon: UIImageView, view: UIView) {
        
        let views = ["icon": icon]
        
        view.addConstraint(NSLayoutConstraint.init(item: icon,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint.init(item: icon,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[icon(65)]",
            options: .alignAllCenterY,
            metrics: nil,
            views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[icon(65)]",
            options: .alignAllCenterX,
            metrics: nil,
            views: views))
    }
}
