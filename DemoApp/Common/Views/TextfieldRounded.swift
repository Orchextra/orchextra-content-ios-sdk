//
//  TextfieldRounded.swift
//  OCMDemo
//
//  Created by Judith Medina on 27/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit


class TextfieldRounded: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 5
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 25))
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 25))
    }
}
