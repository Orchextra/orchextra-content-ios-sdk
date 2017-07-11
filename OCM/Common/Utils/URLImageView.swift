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
    var cached: Bool = false {
        didSet {
            self.cachedIcon?.isHidden = !cached
        }
    }
    var cachedIcon: UIView?
    
    // MARK: - Initalizers
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    // MARK: - Configuration
    
    private func setup() {
        let icon = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        icon.backgroundColor = .white
        icon.isHidden = true
        self.addSubview(icon, settingAutoLayoutOptions: [.margin(to: self, top: nil, bottom: 10, left: nil, right: 5)])
        self.cachedIcon = icon
    }
    
}
