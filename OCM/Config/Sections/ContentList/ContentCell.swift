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
	
	// MARK: - UI Properties
    @IBOutlet weak var fakeMarginsView: UIView!
    @IBOutlet weak var imageContent: URLImageView!
    @IBOutlet weak private var highlightedImageView: UIImageView!
    @IBOutlet weak var customizationView: UIView!
    
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
        
        self.imageContent.backgroundColor = UIColor(white: 0, alpha: 0.08)
        
        let thumbnail = Config.thumbnailEnabled ? (UIImage(data: imageThumbnail) ?? Config.contentListStyles.placeholderImage) : Config.contentListStyles.placeholderImage
        
        self.imageContent.url = url
        self.imageContent.frame = self.bounds
        ImageDownloadManager.shared.downloadImage(with: url, in: self.imageContent, placeholder: thumbnail)
        
        self.highlightedImageView.image = UIImage(named: "content_highlighted")

        if let customProperties = self.content.customProperties {
            self.customizationView.isHidden = false
            OCM.shared.customBehaviourDelegate?.contentNeedsCustomization(
                with: customProperties,
                viewType: .gridContent,
                completion: { (customizations) in
                    guard let customizations = customizations else { return }
                    customizations.forEach { customization in
                        switch customization {
                        case .viewLayer(let view):
                            self.customizationView.addSubviewWithAutolayout(view)
                        case .darkLayer(alpha: let alpha):
                            let view = UIView()
                            view.backgroundColor = .black
                            view.alpha = alpha
                            self.customizationView.addSubviewWithAutolayout(view)
                        case .lightLayer(alpha: let alpha):
                            let view = UIView()
                            view.backgroundColor = .white
                            view.alpha = alpha
                            self.customizationView.addSubviewWithAutolayout(view)
                        case .grayscale:
                            let image = self.imageContent.image?.grayscale()
                            self.imageContent.image = image
                        default:
                            LogWarn("This customization \(customization) hasn't any representation for the grid content view.")
                        }
                    }
            })
        } else {
            self.customizationView.isHidden = true
        }
	}
    
    func refreshImage() {
        if let url = self.imageContent.url {
            ImageDownloadManager.shared.downloadImage(with: url, in: self.imageContent, placeholder: self.imageContent.image)
        }
    }
    
    func highlighted(_ highlighted: Bool) {
        self.highlightedImageView.alpha = highlighted ? 0.3 : 0
    }

}
