//
//  PreviewView.swift
//  OCM
//
//  Created by Sergio López on 7/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewImageView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradingImageView: UIImageView!
    
    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewImageView? {
        guard let previewView = Bundle.OCMBundle().loadNibNamed("PreviewView", owner: self, options: nil)?.first as? PreviewImageView else { return PreviewImageView() }
        return previewView
    }
    
    func load(preview: PreviewImageAndText) {
        self.titleLabel.html = preview.text
        
        self.gradingImageView.image = self.gradingImage(forPreview: preview)
        
        if let urlString = preview.imageUrl {
            self.imageView.imageFromURL(urlString: urlString, placeholder: Config.placeholder)
        }
    }
    
    // MARK: - Convenience Methods

    func gradingImage(forPreview preview: PreviewImageAndText) -> UIImage? {
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
