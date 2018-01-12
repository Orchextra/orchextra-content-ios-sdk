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
        
        self.imageContent.image = thumbnail
        ImageDownloadManager.shared.downloadImage(with: url) { image, _ in
            DispatchQueue.main.async {
                if self.imageContent.url == url {
                    UIView.transition(
                        with: self.imageContent,
                        duration: 0.4,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.imageContent.clipsToBounds = true
                            self.imageContent.contentMode = .scaleAspectFill
                            self.imageContent.image = image
                            if let customProperties = self.content.customProperties, let customizations = OCM.shared.customBehaviourDelegate?.customizationForContent(with: customProperties, viewType: .gridContent), let image = image {
                                customizations.forEach { customization in
                                    switch customization {
                                    case .grayscale:
                                        self.imageContent.image = image.grayscale()
                                    default:
                                        break
                                    }
                                }
                            }
                        },
                        completion: nil)
                }
            }
            
        }
        
        self.highlightedImageView.image = UIImage(named: "content_highlighted")
        
        guard let customProperties = self.content.customProperties, let customizations = OCM.shared.customBehaviourDelegate?.customizationForContent(with: customProperties, viewType: .gridContent) else { return }
        customizations.forEach { customization in
            switch customization {
            case .viewLayer(let view):
                self.addSubviewWithAutolayout(view)
            case .darkLayer(alpha: let alpha):
                let view = UIView()
                view.backgroundColor = .black
                view.alpha = alpha
                self.addSubviewWithAutolayout(view)
            case .lightLayer(alpha: let alpha):
                let view = UIView()
                view.backgroundColor = .white
                view.alpha = alpha
                self.addSubviewWithAutolayout(view)
            case .grayscale:
                let image = self.imageContent.image?.grayscale()
                self.imageContent.image = image
            default:
                LogWarn("This customization \(customization) hasn't any representation for the grid content view.")
            }
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
