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
    
    // MARK: - PUBLIC
    
    class func instantiate() -> PreviewListView? {
        
        guard let previewListView = Bundle.OCMBundle().loadNibNamed("PreviewListView", owner: self, options: nil)?.first as? PreviewListView else { return PreviewListView() }
        return previewListView
    }
    
    func load(preview: PreviewList) {
        
        LogWarn("Load the Preview List !!!")
        backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
    }
    
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
