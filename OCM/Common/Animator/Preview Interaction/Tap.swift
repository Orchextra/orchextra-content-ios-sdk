//
//  Tap.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

class Tap: NSObject, Behaviour {
    
    weak var scroll: UIScrollView?
    weak var previewView: UIView?
    weak var content: OrchextraViewController?
    var manager = ScrollViewToVisibleManager()
    
    // MARK: - Init
    
    required init(scroll: UIScrollView, previewView: UIView, content: OrchextraViewController?) {
        self.scroll = scroll
        self.previewView = previewView
        self.content = content
        super.init()
        configure()
    }
    
    // MARK: - Private
    
    func configure() {
        self.scroll?.isScrollEnabled = false
    }
    
    // MARK: - Behaviour
    
    func performAction(with info: Any?) {
        if self.content != nil, let scroll = self.scroll, let previewView = self.previewView {
            self.manager.scrollView = scroll
            self.manager.scrollRectToVisible(
                CGRect(x: 0, y: previewView.frame.height, width: previewView.frame.width, height: scroll.frame.height),
                animated: true) { [unowned self] in
                    let preview = self.previewView as? PreviewView
                    preview?.previewWillDissapear()
                    self.previewView?.removeFromSuperview()
                    self.scroll?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) // Scrolls to top
                    self.scroll?.isScrollEnabled = true
                    preview?.previewDidAppear()
                    preview?.delegate?.previewViewDidPerformBehaviourAction()
            }
        }
    }
}
