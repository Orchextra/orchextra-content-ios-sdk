//
//  Tap.swift
//  OCM
//
//  Created by Sergio López on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class Tap: NSObject, Behaviour {
    
    weak var scroll: UIScrollView?
    weak var previewView: UIView?
    weak var content: UIViewController?
    var manager = ScrollViewToVisibleManager()
    
    // MARK: - Init
    
    required init(scroll: UIScrollView, previewView: UIView, content: UIViewController?) {
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
                animated: true,
                duration: 0.5) { [unowned self] _ in
                    let preview = self.previewView as? PreviewView
                    preview?.previewWillDissapear()
                    self.previewView?.removeFromSuperview()
                    self.scroll?.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
                    self.scroll?.isScrollEnabled = true
                    preview?.previewDidAppear()
                    preview?.delegate?.previewViewDidPerformBehaviourAction()
            }
        } else {
            guard let preview = self.previewView as? PreviewView else {
                LogWarn("Preview is not a PreviewView")
                return
            }
            preview.delegate?.previewViewDidPerformBehaviourAction()
        }
    }
    
    func previewDidAppear() {}

}
