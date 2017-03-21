//
//  ErrorView.swift
//  OCM
//
//  Created by Carlos Vicente on 16/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

//class DefaultErrorView: ErrorView {
//    
//    // MARK: ErrorView protocol
//    static func instantiate() -> ErrorView {
//        return DefaultErrorView()
//    }
//    
//    func set(errorDescription: String) {
//    }
//
//    func set(retryBlock: @escaping () -> Void) {
//    }
//    
//    func view() -> UIView {
//        let kTopMargin = 99
//        let kBottomMargin = 12
//        let errorView = UIView(frame: .zero)
//        errorView.translatesAutoresizingMaskIntoConstraints = false
//        errorView.backgroundColor = UIColor.OCM.gray
//        let infoErrorView = self.infoErrorView()
//        errorView.addSubview(infoErrorView)
//        
//        let views   = ["errorView"     : errorView,
//                       "infoErrorView" : infoErrorView]
//        let metrics = ["topMargin"     : kTopMargin,
//                       "bottomMargin"  : kBottomMargin]
//        
//        errorView.addConstraint(
//            NSLayoutConstraint(
//                item: infoErrorView,
//                attribute: .centerX,
//                relatedBy: .equal,
//                toItem: errorView,
//                attribute: .centerX,
//                multiplier: 1,
//                constant: 0)
//        )
//        
//        errorView.addConstraint(
//            NSLayoutConstraint(
//                item: infoErrorView,
//                attribute: .width,
//                relatedBy: .equal,
//                toItem: errorView,
//                attribute: .width,
//                multiplier: 1,
//                constant: 0)
//        )
//        
//        errorView.addConstraints(
//            NSLayoutConstraint.constraints(
//                withVisualFormat: "V:|-topMargin-[activityIndicatorView]-(>=bottomMargin)-|",
//                options: .alignAllTrailing,
//                metrics: metrics,
//                views: views
//            )
//        )
//        
//        return errorView
//    }
//
//    // MARK: Private methods
//}
