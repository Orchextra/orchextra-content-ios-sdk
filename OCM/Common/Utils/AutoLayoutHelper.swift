//
//  AutoLayoutHelper.swift
//  OCM
//
//  Created by José Estela on 4/4/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

struct AutoLayoutOption {
    
    fileprivate var value: Any?
    
    static func margin(to view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewMargin(to: view, top: top, bottom: bottom, left: left, right: right))
    }
    
    static func zeroMargin(to view: UIView) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewMargin.zero(to: view))
    }
    
    static func height(_ height: CGFloat, priority: UILayoutPriority = 1000) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewHeight(height: height, priority: priority))
    }
    
    static func width(_ width: CGFloat, priority: UILayoutPriority = 1000) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewWidth(width: width, priority: priority))
    }
    
    static func centerX(to view: UIView) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewCenter(to: view, centerX: true, centerY: false))
    }
    
    static func centerY(to view: UIView) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewCenter(to: view, centerX: false, centerY: true))
    }
}

fileprivate struct ViewMargin {
    fileprivate let view: UIView
    fileprivate var top: CGFloat?
    fileprivate var bottom: CGFloat?
    fileprivate var left: CGFloat?
    fileprivate var right: CGFloat?
    
    static func zero(to view: UIView) -> ViewMargin {
        return ViewMargin(to: view, top: 0, bottom: 0, left: 0, right: 0)
    }
    
    init(to view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) {
        self.view = view
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}

fileprivate struct ViewCenter {
    fileprivate let to: UIView
    fileprivate var centerX: Bool = false
    fileprivate var centerY: Bool = false
}

fileprivate struct ViewWidth {
    fileprivate let width: CGFloat
    fileprivate let priority: UILayoutPriority
}

fileprivate struct ViewHeight {
    fileprivate let height: CGFloat
    fileprivate let priority: UILayoutPriority
}

extension UIView {
    
    func addSubview(_ view: UIView, settingAutoLayoutOptions options: [AutoLayoutOption]) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        view.set(autoLayoutOptions: options)
    }
    
    func inserSubview(_ view: UIView, at index: Int = 0, settingAutoLayoutOptions options: [AutoLayoutOption]) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(view, at: index)
        view.set(autoLayoutOptions: options)
    }
    
    func insertSubview(_ view: UIView, belowSubview subview: UIView, settingAutoLayoutOptions options: [AutoLayoutOption]) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(view, belowSubview: subview)
        view.set(autoLayoutOptions: options)
    }
    
    func set(autoLayoutOptions options: [AutoLayoutOption]) {
        for option in options {
            if let margin = option.value as? ViewMargin {
                self.setMargins(margin, to: margin.view)
            } else if let center = option.value as? ViewCenter {
                if center.centerX {
                    self.setCenterX(to: center.to)
                }
                if center.centerY {
                    self.setCenterY(to: center.to)
                }
            } else if let height = option.value as? ViewHeight {
                self.setLayoutHeight(height.height, priority: height.priority)
            } else if let width = option.value as? ViewWidth {
                self.setLayoutWidth(width.width, priority: width.priority)
            }
        }
    }
    
    private func setCenterX(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        self.addConstraint(constraint)
    }
    
    private func setCenterY(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: view,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0
        )
        self.addConstraint(constraint)
    }
    
    private func setLayoutHeight(_ height: CGFloat, priority: UILayoutPriority = 1000) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: height
        )
        constraint.priority = priority
        self.addConstraint(constraint)
    }
    
    private func setLayoutWidth(_ width: CGFloat, priority: UILayoutPriority = 1000) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: width
        )
        constraint.priority = priority
        self.addConstraint(constraint)
    }
    
    private func setMargins(_ margin: ViewMargin, to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        if let top = margin.top {
            view.addConstraint(
                NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: top)
            )
        }
        if let bottom = margin.bottom {
            view.addConstraint(
                NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -bottom)
            )
        }
        if let left = margin.left {
            view.addConstraint(
                NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: left)
            )
        }
        if let right = margin.right {
            view.addConstraint(
                NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -right)
            )
        }
    }
}
