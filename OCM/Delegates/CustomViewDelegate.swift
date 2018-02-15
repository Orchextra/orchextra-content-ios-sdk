//
//  CustomViewDelegate.swift
//  OCM
//
//  Created by José Estela on 14/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

//swiftlint:disable class_delegate_protocol

/// This protocol allows the delegate to handle custom views needed by OCM.
///
/// - Since: 3.0
public protocol CustomViewDelegate {
    
    /// Use it to set an error view that will be shown when an error occurs.
    ///
    /// - Parameter error: The error message returned by OCM,
    /// - Returns: The error view.
    /// - Since: 3.0
    func errorView(error: String) -> UIView?
    
    /// Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
    ///
    /// - Returns: The loading view.
    /// - Since: 3.0
    func loadingView() -> UIView?
    
    /// Use it to set a custom view that will be shown when there's no content.
    ///
    /// - Returns: The no content view.
    /// - Since: 3.0
    func noContentView() -> UIView?
    
    /// Use it to set a custom view that will be shown when there's no content associated to a search.
    ///
    /// - Returns: The view for no results in a search.
    /// - Since: 3.0
    func noResultsForSearchView() -> UIView?
    
    /// Use it to set a view that will be show when new content is available.
    ///
    /// - Returns: The new contents available view.
    /// - Since: 3.0
    func newContentsAvailableView() -> UIView?
}
//swiftlint:enable class_delegate_protocol
