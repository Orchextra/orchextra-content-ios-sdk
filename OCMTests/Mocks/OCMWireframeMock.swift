//
//  OCMWireframeMock.swift
//  OCMTests
//
//  Created by José Estela on 7/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit
@testable import OCMSDK

class OCMWireframeMock: OCMWireframe {
    
    var spyShowYoutubeCalled = false
    var spyShowVideoPlayerCalled = false
    
    func loadContentList(from path: String?) -> UIViewController { return UIViewController() }
    func loadWebView(with action: ActionWebview) -> UIViewController? { return UIViewController() }
    
    func loadYoutubeVC(with videoId: String) -> UIViewController? {
        self.spyShowYoutubeCalled = true
        return UIViewController()
    }
    
    func loadVideoPlayerVC(with video: Video) -> UIViewController? {
        self.spyShowVideoPlayerCalled = true
        return UIViewController()
    }

    func loadCards(with cards: [Card]) -> UIViewController? { return UIViewController() }
    func loadArticle(with article: Article, elementUrl: String?) -> UIViewController? { return UIViewController() }
    func loadMainComponent(with action: Action) -> UIViewController? { return UIViewController() }
    
    func showBrowser(url: URL) {}
    func show(viewController: UIViewController) {}
    func showMainComponent(with action: Action, viewController: UIViewController) {}
    
}
