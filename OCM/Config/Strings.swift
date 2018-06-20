//
//  Strings.swift
//  OCM
//
//  Created by José Estela on 6/7/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation

/// Use this struct to customize strings displayed by OCM
public struct Strings {
    
    public var appName: String
    public var contentError: String
    public var unexpectedError: String
    public var noResultsForSearch: String
    public var internetConnectionRequired: String
    public var passbookErrorUnsupportedVersion: String
    public var okButton: String
    
    // MARK: - Public init
    
    public init() {
        self.appName = String()
        self.contentError = String()
        self.unexpectedError = String()
        self.noResultsForSearch = String()
        self.internetConnectionRequired = String()
        self.passbookErrorUnsupportedVersion = String()
        self.okButton = String()
    }
    
    public init(appName: String?, contentError: String?, unexpectedError: String?, noResultsForSearch: String?, internetConnectionRequired: String?, passbookErrorUnsupportedVersion: String?, okButton: String?) {
        self.appName = appName ?? String()
        self.contentError = contentError ?? String()
        self.unexpectedError = unexpectedError ?? String()
        self.noResultsForSearch = noResultsForSearch ?? String()
        self.internetConnectionRequired = internetConnectionRequired ?? String()
        self.passbookErrorUnsupportedVersion = passbookErrorUnsupportedVersion ?? String()
        self.okButton = okButton ?? String()
    }
}
