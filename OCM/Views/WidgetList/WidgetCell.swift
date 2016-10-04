//
//  WidgetCell.swift
//  OCM
//
//  Created by Alejandro Jiménez on 5/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class WidgetCell: UICollectionViewCell {
	
	fileprivate var widget: Widget!
	fileprivate let imageService = ImageService()
	
	// MARK - UI Properties
	@IBOutlet weak fileprivate var imageWidget: UIImageView!
	

	func bindWidget(_ widget: Widget) {
		self.widget = widget
		
		if let image = self.widget.media.image {
			self.imageWidget.image = image
			return
		}
		
		self.imageWidget.image = Config.placeholder
		
		self.imageService.fetchImage(widget.media.url) { result in
			switch result {
			case .success(let image) where widget == self.widget:
                self.widget.media.image = image
				self.imageWidget.image = image
				
			default:
				break
			}
		}
	}
}
