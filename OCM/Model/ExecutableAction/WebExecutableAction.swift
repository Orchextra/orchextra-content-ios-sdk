//
//  ExecutableActionWeb.swift
//  OCM
//
//  Created by José Estela on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

public enum WebExecutableActionType {
    case webview
    case browser
    case externalBrowser
}

public class WebExecutableAction: ExecutableAction {
    
    public typealias ExecutableActionResponse = UIViewController?
    
    // MARK: - Attributes
    
    public let url: URL
    public let type: WebExecutableActionType
    
    // MARK: - Public methods
    
    public init(url: URL, type: WebExecutableActionType) {
        self.url = url
        self.type = type
    }
    
    func perform(_ completion: @escaping (ExecutableActionResponse) -> Void) {
        let actionWebView = ActionWebview(
            url: self.url,
            federated: nil,
            preview: nil,
            shareInfo: nil,
            resetLocalStorage: false,
            slug: nil
        )
        completion(ActionViewer(action: actionWebView, ocm: OCM.shared).view())
    }
}
