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
	fileprivate let imageService = ImageService()
	
	// MARK - UI Properties
	@IBOutlet weak fileprivate var imageContent: UIImageView!
	
	func bindContent(_ content: Content) {
		self.content = content
		self.imageContent.image = Config.placeholder
        
		guard let url = content.media.url else { return LogWarn("No image url set") }
        self.imageContent.imageFromUrl(urlString: url)
	}
}
