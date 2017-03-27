//
//  PreviewListView.swift
//  OCM
//
//  Created by Carlos Vicente on 22/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

class PreviewListView: UIView, PreviewView {

    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: PreviewView attributes
    weak var delegate: PreviewViewDelegate?
    
    // MARK: PreviewView methods
    func previewDidAppear() {
    }
    
    func previewDidScroll(scroll: UIScrollView) {
    }
    
    func imagePreview() -> UIImageView? {
        return UIImageView()
    }
    
    func show() -> UIView {
        return self
    }
}
