//
//  LoadingViewDefault.swift
//  OCM
//
//  Created by Judith Medina on 21/09/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class LoadingViewDefault: UIView, StatusView {
    
    @IBOutlet var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func instantiate() -> UIView {
        Bundle.OCMBundle().loadNibNamed("LoadingViewDefault", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = Config.styles.primaryColor
        return self
    }
}
