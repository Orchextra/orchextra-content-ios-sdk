//
//  DemoViewController.swift
//  OCMDemo
//
//  Created by Judith Medina on 03/10/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import OCMSDK
import GIGLibrary
import Orchextra

class DemoViewController: UIViewController, OCMDelegate {
    
    @IBOutlet weak var labelSection: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    
    let ocm = OCM.shared
    var menu: [Section] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ocm.delegate = self
        let ocmHost = "https://cm.orchextra.io"
        self.ocm.offlineSupport = false
        self.ocm.host = ocmHost
        self.ocm.logLevel = .debug
        self.ocm.thumbnailEnabled = false
        self.ocm.newContentsAvailableView = NewContentView()
        
        let backgroundImage = UIImage(named: "rectangle8")
        
//        let noContentView = NoContentViewDefault()
//        noContentView.backgroundImage = backgroundImage
//        noContentView.title = "Pardon!"
//        noContentView.subtitle = "Il n'a pas de jet de contenu"
//        self.ocm.noContentView = noContentView
//
//        let errorView = ErrorViewDefault()
//        errorView.backgroundImage = backgroundImage
//        errorView.title = "Ups!"
//        errorView.subtitle = "Nous avons une erreur"
//        errorView.buttonTitle = "RECOMMENCEZ"
//        self.ocm.errorViewInstantiator = errorView
//
//        
//        let loadingView = LoadingViewDefault()
//        loadingView.title = "Chargement"
//        loadingView.backgroundImage = backgroundImage
//        self.ocm.loadingView = loadingView
//
        self.ocm.isLogged = false
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.ocm.backgroundSessionCompletionHandler = appDelegate.backgroundSessionCompletionHandler
        }
        
        self.customize()
        
        let orchextraHost = "https://sdk.orchextra.io"
        let orchextraApiKey = "9d9f74d0a9b293a2ea1a7263f47e01baed2cb0f3"
        let orchextraApiSecret = "6a4d8072f2a519c67b0124656ce6cb857a55276a"
        
        self.ocm.orchextraHost = orchextraHost
        self.ocm.start(apiKey: orchextraApiKey, apiSecret: orchextraApiSecret) { _ in
            self.ocm.loadMenus()
        }
        
//        self.perform(#selector(hideSplashOrx), with: self, afterDelay: 1.0)
    }
    
    // MARK: - UI setup
    
    func customize() {
        let styles = Styles()
        styles.primaryColor = UIColor(fromHexString: "#EB0853")
        styles.placeholderImage = #imageLiteral(resourceName: "thumbnail")
        styles.primaryColor = .darkGray
        self.ocm.styles = styles
        
        let navigationBarStyles = ContentNavigationBarStyles()
        navigationBarStyles.type = .navigationBar
        navigationBarStyles.barBackgroundImage = #imageLiteral(resourceName: "navigation_bar_background")
        navigationBarStyles.buttonBackgroundImage = #imageLiteral(resourceName: "navigation_button_background")
        navigationBarStyles.showTitle = true
        self.ocm.contentNavigationBarStyles = navigationBarStyles
        
        let contentListStyles = ContentListStyles()
        contentListStyles.transitionBackgroundImage = #imageLiteral(resourceName: "color")
        contentListStyles.placeholderImage = #imageLiteral(resourceName: "thumbnailGridTransparent")
        self.ocm.contentListStyles = contentListStyles
        
        let contentListCarouselStyles = ContentListCarouselLayoutStyles()
        contentListCarouselStyles.pageControlOffset = -30
        contentListCarouselStyles.inactivePageIndicatorColor = .gray
        contentListCarouselStyles.autoPlay = true
        self.ocm.contentListCarouselLayoutStyles = contentListCarouselStyles
        
    }
    
    // MARK: - OCMDelegate
    
    func sessionExpired() {
        print("Session expired")
    }
    
    func customScheme(_ url: URLComponents) {
        print("CUSTOM SCHEME: \(url)")
        UIApplication.shared.openURL(url.url!)
    }
    
    func requiredUserAuthentication() {
        print("User authentication needed it.")
        OCM.shared.isLogged = true
    }
    
    func didUpdate(accessToken: String?) {
    }
    
    func userDidOpenContent(with identifier: String) {
        print("Did open content \(identifier)")
    }
    
    func showPassbook(error: PassbookError) {
        var message: String = ""
        switch error {
        case .error:
            message = "Lo sentimos, ha ocurrido un error inesperado"
            break
            
        case .unsupportedVersionError:
            message = "Su dispositivo no es compatible con passbook"
            break
        }
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Title", message: message, preferredStyle: .alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { _ -> Void in
        }
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func menusDidRefresh(_ menus: [Menu]) {
        for menu in menus where menu.sections.count != 0 {
            self.menu = menu.sections
            self.loadSection()
            break
        }
    }
    
    func loadSection() {
        self.menu.first?.openAction(completion: { viewcontroller in
            guard let vc = viewcontroller else {
                LogWarn("No section")
                return
            }
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            self.didMove(toParentViewController: vc)
        })
    }
    
    func federatedAuthentication(_ federated: [String : Any], completion: @escaping ([String : Any]?) -> Void) {
        
        // TODO: Generate CID Token
        LogInfo("Needs federated authentication")
        completion(["sso_token": "U2FsdGVkX1+zsyT1ULUqZZoAd/AANGnkQExYsAnzFlY5/Ff/BCkaSSuhR0/xvy0e"])
    }
}
