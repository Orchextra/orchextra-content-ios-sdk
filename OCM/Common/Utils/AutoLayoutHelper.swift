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
    
    static func margin(to view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil, safeArea: Bool = false) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewMargin(to: view, top: top, bottom: bottom, left: left, right: right, safeArea: safeArea))
    }
    
    static func zeroMargin(to view: UIView) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewMargin.zero(to: view))
    }
    
    static func height(_ height: CGFloat, priority: UILayoutPriority = UILayoutPriority.defaultHigh) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewHeight(height: height, priority: priority))
    }
    
    static func height(comparingTo view: UIView, relation: NSLayoutRelation, multiplier: CGFloat = 1.0) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewHeightCompare(view: view, relation: relation, multiplier: multiplier))
    }
    
    static func width(_ width: CGFloat, priority: UILayoutPriority = UILayoutPriority.defaultHigh) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewWidth(width: width, priority: priority))
    }
    
    static func width(comparingTo view: UIView, relation: NSLayoutRelation, multiplier: CGFloat = 1.0) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewWidthCompare(view: view, relation: relation, multiplier: multiplier))
    }
    
    static func centerX(to view: UIView) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewCenter(view: view, centerX: true, centerY: false))
    }
    
    static func centerY(to view: UIView) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewCenter(view: view, centerX: false, centerY: true))
    }
    
    static func aspectRatio(width: CGFloat, height: CGFloat) -> AutoLayoutOption {
        return AutoLayoutOption(value: ViewAspectRatio(width: width, height: height))
    }
}

private struct ViewMargin {
    fileprivate let view: UIView
    fileprivate var top: CGFloat?
    fileprivate var bottom: CGFloat?
    fileprivate var left: CGFloat?
    fileprivate var right: CGFloat?
    fileprivate let safeArea: Bool
    
    static func zero(to view: UIView) -> ViewMargin {
        return ViewMargin(to: view, top: 0, bottom: 0, left: 0, right: 0)
    }
    
    init(to view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil, safeArea: Bool = false) {
        self.view = view
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
        self.safeArea = safeArea
    }
}


private struct ViewCenter {
    fileprivate let view: UIView
    fileprivate var centerX: Bool = false
    fileprivate var centerY: Bool = false
}

private struct ViewWidth {
    fileprivate let width: CGFloat
    fileprivate let priority: UILayoutPriority
}

private struct ViewHeight {
    fileprivate let height: CGFloat
    fileprivate let priority: UILayoutPriority
}

private struct ViewWidthCompare {
    fileprivate let view: UIView
    fileprivate let relation: NSLayoutRelation
    fileprivate let multiplier: CGFloat
}

private struct ViewHeightCompare {
    fileprivate let view: UIView
    fileprivate let relation: NSLayoutRelation
    fileprivate let multiplier: CGFloat
}

private struct ViewAspectRatio {
    fileprivate let width: CGFloat
    fileprivate let height: CGFloat
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
                    self.setCenterX(to: center.view)
                }
                if center.centerY {
                    self.setCenterY(to: center.view)
                }
            } else if let height = option.value as? ViewHeight {
                self.setLayoutHeight(height.height, priority: height.priority)
            } else if let height = option.value as? ViewHeightCompare {
                self.setLayoutHeightComparing(to: height.view, relation: height.relation, multiplier: height.multiplier)
            } else if let width = option.value as? ViewWidth {
                self.setLayoutWidth(width.width, priority: width.priority)
            } else if let width = option.value as? ViewWidthCompare {
                self.setLayoutWidthComparing(to: width.view, relation: width.relation, multiplier: width.multiplier)
            } else if let aspectRatio = option.value as? ViewAspectRatio {
                self.setAspectRatio(width: aspectRatio.width, height: aspectRatio.height)
            }
        }
    }
    
    private func setCenterX(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0
        )
        view.addConstraint(constraint)
    }
    
    private func setCenterY(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0
        )
        view.addConstraint(constraint)
    }
    
    private func setLayoutHeight(_ height: CGFloat, priority: UILayoutPriority = UILayoutPriority.defaultHigh) {
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
    
    private func setLayoutWidth(_ width: CGFloat, priority: UILayoutPriority = UILayoutPriority.defaultHigh) {
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
    
    private func setLayoutWidthComparing(to view: UIView, relation: NSLayoutRelation, multiplier: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: relation,
                                            toItem: view,
                                            attribute: .width,
                                            multiplier: multiplier,
                                            constant: 0)
        view.addConstraint(constraint)
    }
    
    private func setLayoutHeightComparing(to view: UIView, relation: NSLayoutRelation, multiplier: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: relation,
            toItem: view,
            attribute: .height,
            multiplier: multiplier,
            constant: 0)
        view.addConstraint(constraint)
    }
    
    private func setMargins(_ margin: ViewMargin, to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = margin.top {
            self.addMarginConstraint(attribute: .top, constant: top, safeArea: margin.safeArea, to: view)
        }
        if let bottom = margin.bottom {
            self.addMarginConstraint(attribute: .bottom, constant: -bottom, safeArea: margin.safeArea, to: view)
        }
        if let left = margin.left {
            self.addMarginConstraint(attribute: .leading, constant: left, safeArea: margin.safeArea, to: view)
        }
        if let right = margin.right {
            self.addMarginConstraint(attribute: .trailing, constant: -right, safeArea: margin.safeArea, to: view)
        }
    }
    
    private func addMarginConstraint(attribute: NSLayoutAttribute, constant: CGFloat, safeArea: Bool, to view: UIView) {
        if safeArea, #available(iOS 11, *) {
            view.addConstraint(
                NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: attribute, multiplier: 1.0, constant: constant)
            )
        } else {
            view.addConstraint(
                NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: constant)
            )
        }
    }
    
    private func setAspectRatio(width: CGFloat, height: CGFloat) {
        let aspectRatioConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: self,
                                                       attribute: .width,
                                                       multiplier: (height / width),
                                                       constant: 0)
        self.addConstraint(aspectRatioConstraint)
    }
}
