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
    
    func loadContentList(from path: String?) -> OrchextraViewController { return OrchextraViewController() }
    func loadWebView(with action: ActionWebview) -> OrchextraViewController? { return OrchextraViewController() }
    
    func loadYoutubeVC(with videoId: String) -> OrchextraViewController? {
        self.spyShowYoutubeCalled = true
        return OrchextraViewController()
    }
    
    func loadVideoPlayerVC(with video: Video) -> OrchextraViewController? {
        self.spyShowVideoPlayerCalled = true
        return OrchextraViewController()
    }

    func loadCards(with cards: [Card]) -> OrchextraViewController? { return OrchextraViewController() }
    func loadArticle(with article: Article, elementUrl: String?) -> OrchextraViewController? { return OrchextraViewController() }
    func loadMainComponent(with action: Action) -> UIViewController? { return UIViewController() }
    
    func showBrowser(url: URL) {}
    func show(viewController: UIViewController) {}
    func showMainComponent(with action: Action, viewController: UIViewController) {}
    
}
