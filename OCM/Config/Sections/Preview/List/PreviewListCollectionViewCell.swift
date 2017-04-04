//
//  PreviewListCollectionViewCell.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 03/04/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewListCollectionViewCell: UICollectionViewCell {
    
    var preview: PreviewView?

    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(with preview: PreviewView) {

        self.preview = preview
        let subview = preview.show()
        subview.clipsToBounds = true
        contentView.addSubViewWithAutoLayout(view: subview, withMargin: .zero())
    }
}
