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
    var imagePreview: UIImageView?
    var progressView: UIView?

    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(with preview: PreviewView) {

        self.preview = preview
        if let subview = preview.imagePreview() {
            imagePreview = subview
            subview.clipsToBounds = true
            contentView.addSubViewWithAutoLayout(view: subview, withMargin: .zero())
        }
    }
    
    func prepareForDisplay() {
        
        guard let unwrappedPreview = preview else { return }
        let subview = unwrappedPreview.show()
        contentView.addSubViewWithAutoLayout(view: subview, withMargin: .zero())
        //imagePreview?.removeFromSuperview()
    }
    
    func display() {
        
        
        //self.preview?.previewDidAppear()
    }
    
}
