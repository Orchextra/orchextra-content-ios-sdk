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
    
    // MARK: - Public attributes
    
    let previewView: UIView
    let scroll: UIScrollView
    let content: OrchextraViewController?
    
    // MARK: - Private attributes
    
    private let margin: CGFloat = 100.0
    private var contentHasHisOwnScroll = false
    
    private var swipeIconView: UIView?
    private var swipeIconViewBottomConstraint: NSLayoutConstraint?

    required init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?) {
        self.previewView = previewView
        self.scroll = scroll
        self.scroll.alwaysBounceVertical = true
        self.scroll.isPagingEnabled = true
        self.content = content
        super.init()
        configure()
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
    
    // MARK: - Behaviour
    
    func performAction(with info: Any?) {
        guard let scrollView = info as? UIScrollView else {
            return
        }
        if scrollView.contentOffset.y > self.margin {
            let preview = self.previewView as? PreviewView
            preview?.delegate?.previewViewDidPerformBehaviourAction()
        }
        if content != nil {
            if scroll.contentOffset.y >= previewView.frame.height {
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

    func configure() {
        switch content {
        case is WebVC:
            self.contentHasHisOwnScroll = true
        default:
            self.contentHasHisOwnScroll = false
        }
        self.addSwipeInfo()
    }
}
