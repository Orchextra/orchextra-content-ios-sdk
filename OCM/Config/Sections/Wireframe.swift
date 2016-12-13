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


class Wireframe: NSObject {
	
	let application: Application
    
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
        webview.url = url
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
        
        guard let articleVC = try? Instantiator<ArticleViewController>().viewController() else {
            LogWarn("Couldn't instantiate ArticleViewController")
            return nil
        }
        
        let presenter = ArticlePresenter(article: article)
        presenter.viewController = articleVC
        articleVC.presenter = presenter
        
        return articleVC
    }
    
    func showMainComponent(with action: Action, viewController: UIViewController) {

        let storyboard = UIStoryboard.init(name: "MainContent", bundle: Bundle.OCMBundle())
        
        guard let mainContentVC = storyboard.instantiateViewController(withIdentifier: "MainContentViewController") as? MainContentViewController
            else {
                LogWarn("Couldn't instantiate MainContentViewController")
                return
        }
        
        let presenter = MainPresenter(action: action)
        presenter.viewController = mainContentVC
        mainContentVC.presenter = presenter
        
        

        if let contentListVC = viewController as? ContentListVC {
            showInteractive(isModeModal: true, viewController: contentListVC, controller: mainContentVC)
//            mainContentVC.transitioningDelegate = contentListVC
//            contentListVC.swipeInteraction.wire(viewController: mainContentVC)
//            contentListVC.present(mainContentVC, animated: true, completion: nil)
            
        } else {
            viewController.show(mainContentVC, sender: nil)
        }
    }
    
    func showInteractive(isModeModal: Bool,
                         viewController: ContentListVC, controller: MainContentViewController) {
        
        let operationType: TransitionAnimatorOperation = .Present
        let animator = TransitionAnimator(operationType: operationType, fromVC: viewController, toVC: controller)
        
        animator.presentationBeforeHandler = { containerView, transitionContext in
            containerView.addSubview(controller.view)
            controller.view.layoutIfNeeded()
            
            let sourceImageView = viewController.createTransitionImageView()
            let destinationImageView = controller.createTransitionImageView()
            
            containerView.addSubview(sourceImageView)
            
            controller.presentationBefore()
            
            controller.view.alpha = 0.0
            
            animator.presentationAnimationHandler = { containerView, percentComplete in
                sourceImageView.frame = destinationImageView.frame

                controller.view.alpha = 1.0
            }
            
            animator.presentationCompletionHandler = { containerView, completeTransition in
                sourceImageView.removeFromSuperview()
                viewController.presentationCompletion(completeTransition: completeTransition)
                controller.presentationCompletion(completeTransition: completeTransition)
            }
        }
        
        animator.dismissalBeforeHandler = { containerView, transitionContext in
            if case .Dismiss = viewController.animator!.interactiveType {
                containerView.addSubview(viewController.navigationController!.view)
            } else {
                containerView.addSubview(viewController.view)
            }
            containerView.bringSubview(toFront: controller.view)
            
            let sourceImageView = controller.createTransitionImageView()
            let destinationImageView = viewController.createTransitionImageView()
            containerView.addSubview(sourceImageView)
            
            let sourceFrame = sourceImageView.frame
            let destFrame = destinationImageView.frame
            
            controller.dismissalBeforeAction()
            
            animator.dismissalCancelAnimationHandler = { (containerView: UIView) in
                sourceImageView.frame = sourceFrame
                controller.view.alpha = 1.0
            }
            
            animator.dismissalAnimationHandler = { containerView, percentComplete in
                if percentComplete < -0.05 { return }
                let frame = CGRect(
                    x: destFrame.origin.x - (destFrame.origin.x - sourceFrame.origin.x) * (1 - percentComplete),
                    y: destFrame.origin.y - (destFrame.origin.y - sourceFrame.origin.y) * (1 - percentComplete),
                    width: destFrame.size.width + (sourceFrame.size.width - destFrame.size.width) * (1 - percentComplete),
                    height: destFrame.size.height + (sourceFrame.size.height - destFrame.size.height) * (1 - percentComplete)
                )
                sourceImageView.frame = frame
                controller.view.alpha = 1.0 - (1.0 * percentComplete)
            }
            
            animator.dismissalCompletionHandler = { containerView, completeTransition in
                viewController.dismissalCompletionAction(completeTransition: completeTransition)
                controller.dismissalCompletionAction(completeTransition: completeTransition)
                sourceImageView.removeFromSuperview()
            }
        }
        
        
        if isModeModal {
            animator.interactiveType = .Dismiss
            controller.transitioningDelegate = animator
            viewController.present(controller, animated: true, completion: nil)
        } else {
            animator.interactiveType = .Pop
            if let _nav = viewController.navigationController as? ImageTransitionNavigationController {
                _nav.interactiveAnimator = animator
            }
            viewController.navigationController?.pushViewController(controller, animated: true)
        }
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
