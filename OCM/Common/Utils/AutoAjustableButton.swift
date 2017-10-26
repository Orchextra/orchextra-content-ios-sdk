//
//  AutoAjustableButton.swift
//  OCM
//
//  Created by José Estela on 25/10/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class AutoAjustableButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.reduceFontSizeToWidth(self.width(), toMaxHeight: self.height())
    }
}
