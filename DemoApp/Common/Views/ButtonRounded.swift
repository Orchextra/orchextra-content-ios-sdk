//
//  ButtonRounded.swift
//  CID
//
//  Created by Judith Medina on 10/1/17.
//  Copyright © 2017 Judith Medina. All rights reserved.
//

import UIKit

class ButtonRounded: UIButton {
    
    var color: UIColor = UIColor.white
    
    var imageLeft: UIImage? {
        didSet {
            self.setImage(imageLeft, for: .normal)
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.frame.width/2 - 125)
        }
    }
    
    var title: String? {
        didSet {
            self.setTitle(self.title?.uppercased(), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customize()
    }
    
    func customize() {
        self.layer.cornerRadius = 5
    }

}
