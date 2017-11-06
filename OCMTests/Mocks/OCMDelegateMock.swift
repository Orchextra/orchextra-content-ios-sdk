//
//  OCMDelegateMock.swift
//  OCMTests
//
//  Created by José Estela on 3/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
@testable import OCMSDK

class OCMDelegateMock: OCMDelegate {
    
    // MARK: - Attributes
    
    var spyDidOpenContent = (called: false, identifier: "")
    var spyContentRequiresUserAuthCalled = false
    var contentRequiresUserAuthenticationBlock: (() -> Void)!
    
    // MARK: - OCMDelegate
    
    func customScheme(_ url: URLComponents) {}
    
    func requiredUserAuthentication() {}
    
    func contentRequiresUserAuthentication(_ completion: @escaping () -> Void) {
        self.spyContentRequiresUserAuthCalled = true
        self.contentRequiresUserAuthenticationBlock = completion
    }
    
    func didUpdate(accessToken: String?) {}
    
    func showPassbook(error: PassbookError) {}
    
    func userDidOpenContent(with identifier: String) {
        self.spyDidOpenContent.called = true
        self.spyDidOpenContent.identifier = identifier
    }
    
    func menusDidRefresh(_ menus: [Menu]) {}
    
    func federatedAuthentication(_ federated: [String: Any], completion: @escaping ([String: Any]?) -> Void) {}
    
}
