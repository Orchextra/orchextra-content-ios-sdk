//
//  PreviewView.swift
//  OCM
//
//  Created by Sergio López on 7/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewView? {
        guard let previewView = Bundle.OCMBundle().loadNibNamed("PreviewView", owner: self, options: nil)?.first as? PreviewView else { return PreviewView() }
        return previewView
    }
    
    func load(preview: Preview) {
        self.titleLabel.text = preview.text
        
        if let urlString = preview.imageUrl {
            self.imageView.imageFromURL(urlString: urlString, placeholder: Config.placeholder)
        }
    }
}
