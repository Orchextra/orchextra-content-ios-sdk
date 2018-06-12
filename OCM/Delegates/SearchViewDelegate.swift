//
//  SearchViewDelegate.swift
//  OCM
//
//  Created by José Estela on 12/6/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit

//swiftlint:disable class_delegate_protocol

/// This protocol allows the delegate to handle custom views needed by OCM.
///
/// - Since: 3.0
public protocol SearchViewDelegate {
    
    /// Use it to set an error view that will be shown when an error occurs.
    ///
    /// - Parameter error: The error message returned by OCM
    /// - Parameter reloadBlock: Block called if you want to reload the data of the current content list errored
    /// - Returns: The error view.
    /// - Since: 3.0
    func errorViewForSearch(error: String, reloadBlock: @escaping () -> Void) -> UIView?
    
    /// Use it to set an image wich indicates that something is being loaded but it has not been downloaded yet.
    ///
    /// - Returns: The loading view.
    /// - Since: 3.0
    func loadingViewForSearch() -> UIView?
    
    /// Use it to set a custom view that will be shown when there's no content.
    ///
    /// - Returns: The no content view.
    /// - Since: 3.0
    func noContentViewForSearch() -> UIView?
    
}
