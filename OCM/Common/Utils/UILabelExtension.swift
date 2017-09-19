//
//  UILabelExtension.swift
//  OCM
//
//  Created by José Estela on 23/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func adjustFontSizeForLargestWord() {
        guard let text = self.text else { return }
        let words = text.components(separatedBy: " ") as [NSString]
        let sortedWords = words.sorted(by: {
            $0.size(withAttributes: [NSAttributedStringKey.font: self.font]).width > $1.size(withAttributes: [NSAttributedStringKey.font: self.font]).width
        })
        let fontName = self.font.fontName
        var largeWordSize = sortedWords[0].size(withAttributes: [NSAttributedStringKey.font: self.font])
        while largeWordSize.width > self.frame.size.width {
            let fontSize = self.font.pointSize
            if let font = UIFont(name: fontName, size: fontSize - 1) {
                largeWordSize = sortedWords[0].size(withAttributes: [NSAttributedStringKey.font: font])
                self.font = font
            } else {
                break
            }
        }
    }
}
