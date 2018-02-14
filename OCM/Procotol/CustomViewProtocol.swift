//
//  CustomViewProtocol.swift
//  OCM
//
//  Created by José Estela on 14/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

//swiftlint:disable class_delegate_protocol

/// This protocol allow the delegate to handle custom views needed by OCM
/// - Since: 3.0.0
public protocol CustomViewsDelegate {
    
    /// Use it to set an error view that will be shown when an error occurs
    ///
    /// - Parameter error: The error message returned by OCM
    /// - Returns: The Error View
    func errorView(error: String) -> UIView?
    
    /// Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet
    ///
    /// - Returns: The Laoding View.
    func loadingView() -> UIView?
    
    /// Use it to set a custom view that will be shown when there will be no content.
    ///
    /// - Returns: The No Content View.
    func noContentView() -> UIView?
    
    /// Use it to set a custom view that will be shown when there will be no content associated to a search.
    ///
    /// - Returns: The No Search Result View.
    func noSearchResultView() -> UIView?
    
    /// Use it to set a view that will be show when new content is available.
    ///
    /// - Returns: The New Contents Available View.
    func newContentsAvailableView() -> UIView?
}

//swiftlint:enable class_delegate_protocol
