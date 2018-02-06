//
//  ErrorViewProtocol.swift
//  OCM
//
//  Created by Eduardo Parada on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit

/**
 This protocol is used to mark some views in the application that indicate an error.
 
 - Since: 1.0
 */

public protocol ErrorView {
    
    /**
     Use this method to instantiate a view that implements this protocol.
     
     - Since: 1.0
     */
    func instantiate() -> UIView
    
    /**
     Use this method to set the error description. This allow to manage error information inside the error view.
     
     - Since: 1.0
     */
    func set(errorDescription: String)
    
    /**
     Use this method to provide a block of code that will be executed after user retries the operation that previously falied.
     
     - Since: 1.0
     */
    func set(retryBlock: @escaping () -> Void)
    
    /*
     Returns a view wich indicates that an error has been occured
     
     - returns: The error view.
     
     - Since: 1.0
     */
    func view() -> UIView
}

/**
 This protocol is used to mark some views in the application that indicate a state (such as no results found after a search, loading content or content that requires login to be shown).
 
 - Since: 1.0
 */
public protocol StatusView {
    
    /**
     Use this method to instantiate a view that implements this protocol.
     
     - Since: 1.0
     */
    func instantiate() -> UIView
}
