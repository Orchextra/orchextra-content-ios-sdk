//
//  Wireframe.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary
import SafariServices


class Wireframe: NSObject, WebVCDismissable {
	
	let application: Application
    var animator: TransitionAnimator?

    init(application: Application) {
        self.application = application
    }
	
	func contentList(from path: String? = nil) -> OrchextraViewController {
		guard let contentListVC = try? Instantiator<ContentListVC>().viewController() else {
			LogWarn("Couldn't instantiate ContentListVC")
			return OrchextraViewController()
		}
		
		contentListVC.presenter = ContentListPresenter(
			view: contentListVC,
			contentListInteractor: ContentListInteractor(
				service: ContentListService(),
				storage: Storage.shared
			),
			defaultContentPath: path
		)
		return contentListVC
	}
	
    func showWebView(url: URL) -> OrchextraViewController? {
        guard let webview = try? Instantiator<WebVC>().viewController() else {
            LogWarn("WebVC not found")
            return nil
        }
        
        let passbookWrapper: PassBookWrapper = PassBookWrapper()
        let webInteractor: WebInteractor = WebInteractor(passbookWrapper: passbookWrapper)
        let webPresenter: WebPresenter = WebPresenter(webInteractor: webInteractor, webView: webview)
        
        webview.url = url
        webview.dismissableDelegate = self
        webview.localStorage = Session.shared.localStorage
        webview.presenter = webPresenter
        return webview
	}
    
    func showYoutubeWebView(videoId: String) -> OrchextraViewController? {
        guard let youtubeWebVC = try? Instantiator<YoutubeWebVC>().viewController() else {
            LogWarn("YoutubeWebVC not found")
            return nil
        }
        
        let youtubeWebInteractor: YoutubeWebInteractor = YoutubeWebInteractor(videoId: videoId)
        let youtubeWebPresenter: YoutubeWebPresenter = YoutubeWebPresenter(
            view: youtubeWebVC,
            interactor: youtubeWebInteractor)
        
        youtubeWebVC.presenter = youtubeWebPresenter
        
        return youtubeWebVC
    }
    
    func showYoutubeVC(videoId: String) -> OrchextraViewController? {
        
        guard let youtubeVC = Bundle.OCMBundle().loadNibNamed("YoutubeVC", owner: self, options: nil)?.first as? YoutubeVC else { return YoutubeVC() }
        youtubeVC.loadVideo(id: videoId)
        return youtubeVC
    }
    
    func showBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.application.presentModal(safariVC)
    }
    
    func show(viewController: UIViewController) {
        self.application.presentModal(viewController)
    }
    
    func showArticle(_ article: Article) -> OrchextraViewController? {
        
        let imageTextCard = Card(
            type: "imageText",
            render: JSON(from: [
                "imageUrl": "https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/thumbnail_feed003.png",
                "text": "Proba proba proba",
                "ratios": [Float(0.6), Float(0.4)]
                ]
            )
        )
        
        let imageCard = Card(
            type: "image",
            render: JSON(from: [
                "imageUrl": "https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/thumbnail_feed003.png"
                ]
            )
        )
        
        let imageCard2 = Card(
            type: "image",
            render: JSON(from: [
                "imageUrl": "https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/thumbnail_feed002.png"
                ]
            )
        )
        
        let textImageCard = Card(
            type: "textImage",
            render: JSON(from: [
                "imageUrl": "https://s3-eu-west-1.amazonaws.com/stream-public-dev/woahTest/thumbnail_feed003.png",
                "text": "Proba proba proba asdiasdoiasdas a wsdjkasdjkasasd",
                "ratios": [Float(0.6), Float(0.4)]
                ]
            )
        )
        
        let text = Card(
            type: "richText",
            render: JSON(from: [
                "richText": "<html><b>Lorem ipsum dolor sit amet,</b> consectetur adipiscing elit. Nullam in congue mi, et dignissim tortor. Etiam quis mauris quis erat sollicitudin iaculis. Curabitur ac condimentum lectus. Donec tempor interdum eros, quis dictum velit gravida eget. Nullam suscipit arcu at tortor vehicula dignissim. Fusce viverra eros tortor, ac rutrum magna convallis vel. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Quisque et leo interdum, consectetur neque ut, lacinia neque. Nam varius tellus eget purus sodales, at lobortis nisl malesuada. Vivamus ac vehicula leo, sit amet fringilla nunc. Pellentesque eget varius nulla. Fusce facilisis nisl non lorem porta, eget euismod dui ullamcorper. Morbi gravida mattis risus, ut ullamcorper tellus commodo sit amet. Vivamus fermentum hendrerit ex.Quisque vestibulum varius elit vitae luctus. Fusce ac ornare dolor, et mattis arcu. Curabitur dignissim venenatis eleifend. Praesent rhoncus enim ac arcu cursus placerat. Vestibulum tempor tempus commodo. Nulla ac diam convallis, vulputate dui at, efficitur sapien. Donec in velit erat. Nunc vitae justo at magna convallis blandit. Sed gravida, metus sit amet pharetra tincidunt, lorem turpis maximus justo, ac imperdiet nibh turpis et eros. Ut rutrum efficitur leo vehicula porta. </html>",
                ]
            )
        )

        guard let viewController = try? Instantiator<CardsVC>().viewController() else { return nil }
        let presenter = CardsPresenter(
            view: viewController,
            cards: [
                imageTextCard,
                imageCard,
                textImageCard,
                imageCard2,
                text
            ]
        )
        viewController.presenter = presenter
        return viewController

        /*
        guard let articleVC = try? Instantiator<ArticleViewController>().viewController() else {
            LogWarn("Couldn't instantiate ArticleViewController")
            return nil
        }
        
        let presenter = ArticlePresenter(article: article)
        presenter.viewController = articleVC
        articleVC.presenter = presenter
        return articleVC*/
    }
    
    func showMainComponent(with action: Action, viewController: UIViewController) {

        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                LogWarn("Couldn't instantiate MainContentViewController")
                return
        }
        
        let presenter = MainPresenter(action: action)
        presenter.view = mainContentVC
        mainContentVC.presenter = presenter

        if let contentListVC = viewController as? ContentListVC {
            mainContentVC.transitioningDelegate = mainContentVC
            contentListVC.present(mainContentVC, animated: true, completion: nil)
        } else {
            viewController.show(mainContentVC, sender: nil)
        }
    }
    
    func provideMainComponent(with action: Action) -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                LogWarn("Couldn't instantiate MainContentViewController")
                return nil
        }
        
        let presenter = MainPresenter(action: action)
        presenter.view = mainContentVC
        mainContentVC.presenter = presenter
        return mainContentVC
    }
    
    // MARK: WebVCDismissable methods
    func dismiss(webVC: WebVC) {
      _ = webVC.navigationController?.popViewController(animated: true)
    }
}
class OCMNavigationController: UINavigationController {
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
