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
    
    private var swipeIconView: UIView?
    private var swipeIconViewBottomConstraint: NSLayoutConstraint?

    required init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?, completion: @escaping () -> Void) {
        self.previewView = previewView
        self.scroll = scroll
        self.scroll.alwaysBounceVertical = true
        self.scroll.isPagingEnabled = true
        self.completion = completion
        self.content = content
        super.init()

        switch content {
        case is WebVC:
            self.contentHasHisOwnScroll = true
        case is CardsVC:
            self.contentHasHisOwnScroll = false
        default:
            self.contentHasHisOwnScroll = false
        }
        
        self.addSwipeInfo()
    }
    
    // MARK: - Private
    
    private func addSwipeInfo() {

        // Add swipe icon
        let swipeAnimatedView = self.swipeIcon()
        self.previewView.addSubview(swipeAnimatedView)
        // Add constraints
        gig_autoresize(swipeAnimatedView, false)
        gig_layout_center_horizontal(swipeAnimatedView, 0)
        let constraint = gig_layout_bottom(swipeAnimatedView, 0)
        // Save for forthcoming animation
        self.swipeIconViewBottomConstraint = constraint
        self.swipeIconView = swipeAnimatedView
    }
    
    private func swipeIcon() -> UIImageView {
    
        let swipeIconImageView = UIImageView(image: UIImage.OCM.previewScrollDownIcon)
        swipeIconImageView.alpha = 0.0
        return swipeIconImageView
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
    
    func previewDidAppear() {
        // Animate swipe icon
        self.swipeIconViewBottomConstraint?.constant = -40
        UIView.animate(withDuration: 1.2,
                       delay: 0.3,
                       options: [.curveEaseInOut, .repeat],
                       animations: { 
                        self.previewView.layoutIfNeeded()
                        self.swipeIconView?.alpha = 1.0
        },
                       completion: nil)
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
