//
//  UIScrollViewExtension.swift
//  OCM
//
//  Created by José Estela on 6/4/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewToVisibleManager: NSObject, UIScrollViewDelegate {
    
    // MARK: - Attributes
    
    weak var scrollView: UIScrollView?
    weak var oldDelegate: UIScrollViewDelegate?
    var completion: (() -> Void)?
    
    // MARK: - Public methods
    
    func scrollRectToVisible(_ rect: CGRect, animated: Bool, completion: @escaping () -> Void) {
        self.completion = completion
        self.oldDelegate = self.scrollView?.delegate
        self.scrollView?.delegate = self
        self.scrollView?.scrollRectToVisible(rect, animated: animated)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let oldDelegate = self.oldDelegate else { return }
        if oldDelegate.responds(to: #selector(scrollViewDidScroll(_:))) {
            self.oldDelegate?.scrollViewDidScroll!(scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.completion?()
        guard let oldDelegate = self.oldDelegate else { return }
        if oldDelegate.responds(to: #selector(scrollViewDidEndScrollingAnimation(_:))) {
            self.oldDelegate?.scrollViewDidEndDecelerating!(scrollView)
        }
        self.scrollView?.delegate = self.oldDelegate
    }
}
