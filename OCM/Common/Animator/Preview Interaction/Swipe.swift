//
//  Swipe.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class Swipe: NSObject, Behaviour {
    
    let previewView: UIView
    let scroll: UIScrollView
    let completion: () -> Void
    private var contentHasHisOwnScroll = false
    let content: OrchextraViewController?
    let margin: CGFloat = 100.0

    required init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?, completion: @escaping () -> Void) {
        self.previewView = previewView
        self.scroll = scroll
        self.scroll.alwaysBounceVertical = true
        self.scroll.isPagingEnabled = true
        self.completion = completion
        self.content = content
        super.init()

        if let _ = content as? WebVC {
            self.contentHasHisOwnScroll = true
        }
        
        self.addSwipeInfo()
    }
    
    // MARK: - Private
    
    private func addSwipeInfo() {

        let swipeImageView = self.swipeImageView()
        let swipeLabel = self.swipeLabel()
        
        self.previewView.addSubview(swipeLabel)
        self.previewView.addSubview(swipeImageView)

        gig_autoresize(swipeLabel, false)
        gig_layout_center_horizontal(swipeLabel, 0)
        
        gig_autoresize(swipeImageView, false)
        gig_layout_center_horizontal(swipeImageView, 0)
        gig_layout_bottom(swipeImageView, 16)
        
        gig_layout_below(swipeImageView, swipeLabel, 10)
    }
    
    private func swipeLabel() -> UILabel {
        let infoLabel = UILabel(frame: CGRect.zero)
        infoLabel.alpha = 0.3
        infoLabel.styledString = Localize("preview_slide_text").style(.bold, .color(.white), .fontName("Gotham-Ultra"), .size(15), .letterSpacing(2.5))
        return infoLabel
    }
    
    private func swipeImageView() -> UIImageView {
        let swipeImageView = UIImageView(image: UIImage.OCM.swipe)
        self.previewView.addSubview(swipeImageView)
        return swipeImageView
    }

    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > self.margin {
            completion()
        }

        if content != nil {
            if scroll.contentOffset.y > previewView.frame.height {
                scroll.isPagingEnabled = false
                if contentHasHisOwnScroll {
                    self.scroll.isScrollEnabled = false
                }
            } else {
                scroll.isPagingEnabled = true
                if contentHasHisOwnScroll {
                    self.scroll.isScrollEnabled = true
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
    
    /*func contentScrollDidScroll(_ contentScroll: UIScrollView) {
        
        if contentScroll.contentOffset.y <= 0 {
            contentScroll.setContentOffset(CGPoint.zero, animated: false)
            self.scroll.isScrollEnabled = true
            
        } else {
            self.scroll.isScrollEnabled = false
            contentScroll.isScrollEnabled = true
        }
    }*/
}
