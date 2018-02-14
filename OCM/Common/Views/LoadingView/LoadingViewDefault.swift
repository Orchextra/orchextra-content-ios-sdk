//
//  LoadingViewDefault.swift
//  OCM
//
//  Created by Judith Medina on 21/09/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

open class LoadingViewDefault: UIView {
    
    // MARK: - Public properties
    
    open var backgroundImage: UIImage?
    open var title: String?
    
    // MARK: - Private properties
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var loadingTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func instantiate() -> UIView {
        Bundle.OCMBundle().loadNibNamed("LoadingViewDefault", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = UIColor.clear
        
        backImage.image = backgroundImage
        
        if let titleText = title {
            self.loadingTitle.text = titleText
        }

        return self
    }
}
