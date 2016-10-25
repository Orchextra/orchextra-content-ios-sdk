//
//  ContentCell.swift
//  OCM
//
//  Created by Alejandro Jiménez on 5/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
//import GIGLibrary

class ContentCell: UICollectionViewCell {
	
	fileprivate var content: Content!
	
	// MARK - UI Properties
    @IBOutlet weak fileprivate var imageContent: UIImageView!

    // MARK: - View Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Use this instead of Autolayout to avoid a bug where the UImageView doens't have exactly the same size as the cell in some cases.
        self.imageContent.frame = self.bounds
    }
	
    // MARK: - PUBLIC
    
	func bindContent(_ content: Content) {
		self.content = content
		self.imageContent.image = Config.placeholder
		guard let url = content.media.url else { return LogWarn("No image url set") }
        self.imageContent.ocmImageFromURL(urlString: url)
	}
}
