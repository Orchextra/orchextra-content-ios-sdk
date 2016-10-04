//
//  WidgetCell.swift
//  OCM
//
//  Created by Alejandro Jiménez on 5/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class WidgetCell: UICollectionViewCell {
	
	private var widget: Widget!
	private let imageService = ImageService()
	
	// MARK - UI Properties
	@IBOutlet weak private var imageWidget: UIImageView!
	

	func bindWidget(widget: Widget) {
		self.widget = widget
		
		if let image = self.widget.media.image {
			self.imageWidget.image = image
			return
		}
		
		self.imageWidget.image = Config.placeholder
		
		self.imageService.fetchImage(widget.media.url) { result in
			switch result {
			case .Success(let image) where widget == self.widget:
                self.widget.media.image = image
				self.imageWidget.image = image
				
			default:
				break
			}
		}
	}
}
