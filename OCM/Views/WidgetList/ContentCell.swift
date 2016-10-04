//
//  ContentCell.swift
//  OCM
//
//  Created by Alejandro Jiménez on 5/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class ContentCell: UICollectionViewCell {
	
	fileprivate var content: Content!
	fileprivate let imageService = ImageService()
	
	// MARK - UI Properties
	@IBOutlet weak fileprivate var imageContent: UIImageView!
	

	func bindContent(_ content: Content) {
		self.content = content
		
		if let image = self.content.media.image {
			self.imageContent.image = image
			return
		}
		
		self.imageContent.image = Config.placeholder
		
		self.imageService.fetchImage(content.media.url) { result in
			switch result {
			case .success(let image) where content == self.content:
                self.content.media.image = image
				self.imageContent.image = image
				
			default:
				break
			}
		}
	}
}
