//
//  Swipe.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class Swipe: NSObject, Behaviour, UIScrollViewDelegate {
    
    let previewView: UIView
    let scroll: UIScrollView
    let completion: () -> Void
    var completionCalled = false
    
    let existContentBelow: Bool
    
    required init(scroll: UIScrollView, previewView: UIView, existContentBelow: Bool, completion: @escaping () -> Void) {
        self.previewView = previewView
        self.scroll = scroll
        self.scroll.isPagingEnabled = true
        self.completion = completion
        self.existContentBelow = existContentBelow
        super.init()
        
        scroll.delegate = self
        self.addSwipeInfo()
    }
    
    // MARK: - Private
    
    func addSwipeInfo() {
        let swipeImageView = UIImageView(image: UIImage.OCM.swipe)
        self.previewView.addSubview(swipeImageView)
        
        gig_autoresize(swipeImageView, false)
        gig_layout_center_horizontal(swipeImageView, 0)
        gig_layout_bottom(swipeImageView, 16)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !completionCalled {
            completion()
            completionCalled = true
        }

        if existContentBelow {
            if scroll.contentOffset.y > previewView.frame.height {
                scroll.isPagingEnabled = false
            } else {
                scroll.isPagingEnabled = true
            }
        }
    }
}
