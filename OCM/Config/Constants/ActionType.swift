//
//  ActionTypes.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 13/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


struct ActionTypeValue {
	static let content = "openContent"
    static let article = "article"
    static let webview = "webview"
    static let browser = "browser"
    static let externalBrowser = "externalBrowser"
    static let deepLink = "deepLink"
    static let scan = "scan"
    static let vuforia = "vuforia"
    static let video = "video"
    static let card = "articleCard"
}

enum ActionType {
    case content
    case article
    case webview
    case browser
    case externalBrowser
    case deepLink
    case scan
    case vuforia
    case video
    case card
    case banner
}
