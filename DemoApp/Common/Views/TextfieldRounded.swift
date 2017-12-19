//
//  TextfieldRounded.swift
//  OCMDemo
//
//  Created by Judith Medina on 27/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

// swiftlint:disable legacy_constructor

class TextfieldRounded: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, 8, 0, 25))
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, 8, 0, 25))
    }
}

// swiftlint:enable legacy_constructor
