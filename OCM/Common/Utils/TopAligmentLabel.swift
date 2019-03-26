//
//  TopAligmentLabel.swift
//  OCM
//
//  Created by José Estela on 24/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class TopAlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        if let stringText = text, let font = font {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width, height: self.frame.size.height),
                                                                    options: .usesLineFragmentOrigin,
                                                                    attributes: [.font: font],
                                                                    context: nil).size
            super.drawText(in: CGRect(x: 0, y: 0, width: self.frame.width, height: ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
