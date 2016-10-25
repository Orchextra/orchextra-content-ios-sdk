//
//  Tap.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class Tap: NSObject, Behaviour, UIScrollViewDelegate {
    
    let scroll: UIScrollView
    let previewView: UIView
    
    // MARK: - Init
    
    required init(scroll: UIScrollView, previewView: UIView) {
        self.scroll = scroll
        self.previewView = previewView
        super.init()
    
        self.configureScroll()
        self.addTapButton()
    }
    
    // MARK: - PRIVATE
    
    func configureScroll() {
        scroll.isScrollEnabled = false
        scroll.delegate = self
    }
    
    func addTapButton() {
        let tapButton = UIButton(type: .custom)
        tapButton.addTarget(self, action: #selector(didTapPreviewView), for: .touchUpInside)
        previewView.addSubviewWithAutolayout(tapButton)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scroll.isScrollEnabled = true
        self.previewView.removeFromSuperview()
        self.scroll.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) // Scrolls to top
    }
    
    // MARK: - PRIVATE
    
    @objc func didTapPreviewView(_ scrollView: UIScrollView) {
        
        self.scroll.scrollRectToVisible(CGRect(x: 0, y: previewView.frame.height, width: previewView.frame.width, height: self.scroll.frame.height), animated: true)
    }
}
