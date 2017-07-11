//
//  URLImageView.swift
//  OCM
//
//  Created by José Estela on 27/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

/// Represents an image vie with url attribute
class URLImageView: UIImageView {
    
    /// The url of the image
    var url: String?
    
    // MARK: - Initalizers
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
