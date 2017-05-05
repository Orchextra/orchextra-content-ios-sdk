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
        infoLabel.styledString = localize("preview_slide_text").style(.bold, .color(.white), .fontName("Gotham-Ultra"), .size(15), .letterSpacing(2.5))
        return infoLabel
    }
    
    private func swipeImageView() -> UIImageView {
        let swipeImageView = UIImageView(image: UIImage.OCM.swipe)
        self.previewView.addSubview(swipeImageView)
        return swipeImageView
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
