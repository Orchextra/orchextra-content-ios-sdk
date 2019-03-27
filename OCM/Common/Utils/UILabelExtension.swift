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
        guard let text = self.text,
            let font = self.font else { logWarn("text is nil"); return }
        let words = text.components(separatedBy: " ") as [NSString]
        let sortedWords = words.sorted(by: {
            $0.size(withAttributes: [.font: font]).width > $1.size(withAttributes: [.font: font]).width
        })
        let fontName = self.font.fontName
        var largeWordSize = sortedWords[0].size(withAttributes: [.font: font])
        while largeWordSize.width > self.frame.size.width {
            let fontSize = self.font.pointSize
            if let font = UIFont(name: fontName, size: fontSize - 1) {
                largeWordSize = sortedWords[0].size(withAttributes: [.font: font])
                self.font = font
            } else {
                break
            }
        }
    }
    
    func reduceFontSizeToWidth(_ width: CGFloat, toMaxHeight height: CGFloat) {
        guard let string = self.text else { logWarn("text is nil"); return }
        var stringHeight = string.height(withConstrainedWidth: width, font: self.font)
        while stringHeight > height {
            let fontSize = self.font.pointSize
            if let font = UIFont(name: self.font.fontName, size: fontSize - 1) {
                stringHeight = string.height(withConstrainedWidth: width, font: font)
                self.font = font
            } else {
                break
            }
        }
    }
}
