//
//  Swipe.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class Swipe: NSObject, Behaviour, UIScrollViewDelegate {
    
    let previewView: UIView
    let scroll: UIScrollView
    
    required init(scroll: UIScrollView, previewView: UIView) {
        self.previewView = previewView
        self.scroll = scroll
        self.scroll.isPagingEnabled = true
        
        super.init()
        
        scroll.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scroll.contentOffset.y > previewView.frame.height {
            scroll.isPagingEnabled = false
        } else {
            scroll.isPagingEnabled = true
        }
    }
}
