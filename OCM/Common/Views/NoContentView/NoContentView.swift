//
//  NoContentView.swift
//  OCM
//
//  Created by Judith Medina on 21/09/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

open class NoContentViewDefault: UIView {
    
    // MARK: - Public properties
    
    open var backgroundImage: UIImage?
    open var title: String?
    open var subtitle: String?

    // MARK: - Private properties

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func instantiate() -> UIView {
        Bundle.OCMBundle().loadNibNamed("NoContentViewDefault", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = Config.styles.primaryColor
        backImage.image = backgroundImage
        
        if let titleText = title {
            self.titleLabel.text = titleText
        }
        
        if let subtitleText = subtitle {
            self.subtitleLabel.text = subtitleText
        }
        
        return self
    }
}
