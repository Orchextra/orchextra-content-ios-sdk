//
//  MenuCell.swift
//  TabLayoutDemo
//
//  Created by Sergio López on 27/9/16.
//  Copyright © 2016 Sergio López. All rights reserved.
//

import UIKit

class SectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var barView: UIView!
    
    // MARK: Overriden Properties
    
    override var isSelected: Bool {
        didSet {
            if isSelected != oldValue {
                UIView.animate(withDuration: 0.15, animations: {
                    self.highlight(self.isSelected)
                })
            } else {
                self.highlight(self.isSelected)
            }
        }
    }
    
    // MARK: PUBLIC

    func name(_ name: String) {
        self.sectionLabel.styledString = name.uppercased().style(.letterSpacing(2.0))
        self.highlight(false)
    }
    
    // MARK: PRIVATE
    
    func highlight(_ highlight: Bool) {
        if highlight {
            self.barView.alpha = 1
            self.barView.transform = CGAffineTransform.identity
            
            self.sectionLabel.alpha = 1
            
        } else {
            self.barView.alpha = 0
            self.barView.transform = CGAffineTransform(scaleX: 0.3, y: 1)
            
            self.sectionLabel.alpha =  0.4
        }
    }
}
