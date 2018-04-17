//
//  ErrorDelegate.swift
//  OCM
//
//  Created by José Estela on 10/4/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation

//swiftlint:disable class_delegate_protocol
/// This protocol informs the delegate about non-fatal errors on OCM
public protocol ErrorDelegate {
    
    /// Informs the delegate that an error occured when attempting to open a content
    ///
    /// - Parameter error: Error type for non-fatal event.
    func openContentFailed(with error: OCMError)
}
//swiftlint:enable class_delegate_protocol
