//
//  Tap.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class Tap: NSObject, Behaviour {
    
    let scroll: UIScrollView
    let previewView: UIView
    let completion: () -> Void
    let content: OrchextraViewController?
    var tapButton: UIButton?
    
    // MARK: - Init
    
    required init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?, completion: @escaping () -> Void) {
        self.scroll = scroll
        self.previewView = previewView
        self.completion = completion
        self.content = content
        super.init()
        
        self.configureScroll()
        self.addTapButton()
    }
    
    // MARK: - PRIVATE
    
    func configureScroll() {
        scroll.isScrollEnabled = false
    }
    
    func addTapButton() {
        self.tapButton = UIButton(type: .custom)
        self.tapButton?.backgroundColor = .clear
        self.tapButton?.addTarget(self, action: #selector(didTapPreviewView), for: .touchUpInside)
        if let tapButton = self.tapButton {
            self.previewView.addSubviewWithAutolayout(tapButton)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.previewView.removeFromSuperview()
        self.scroll.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) // Scrolls to top
        self.scroll.isScrollEnabled = true
    }
    
    /*func contentScrollDidScroll(_ scrollView: UIScrollView) {
     
     }*/
    
    // MARK: - PRIVATE
    
    @objc func didTapPreviewView(_ scrollView: UIScrollView) {
        
        completion()
        
        if content != nil {
            self.scroll.scrollRectToVisible(CGRect(x: 0, y: previewView.frame.height, width: previewView.frame.width, height: self.scroll.frame.height), animated: true)
        }
    }
}
