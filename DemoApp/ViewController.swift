//
//  ViewController.swift
//  DemoApp
//
//  Created by Alejandro Jiménez Agudo on 30/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import OCMSDK
import GIGLibrary
import Orchextra

class ViewController: UIViewController, OCMDelegate {

    let ocm = OCM.shared
    var menu: [Section] = []
    let session = Session.shared
    let appController = AppController.shared
    
    @IBOutlet weak var sectionsMenu: SectionsMenu!
    @IBOutlet weak var pagesContainer: PagesContainerScroll!
    @IBOutlet weak var logoOrx: UIImageView!
    @IBOutlet weak var labelOrx: UILabel!
    @IBOutlet weak var splashOrx: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ocm.delegate = self
        self.ocm.customBehaviourDelegate = self
        self.ocm.eventDelegate = self
        let ocmHost = "https://" + InfoDictionary("OCM_HOST")
        self.ocm.host = ocmHost
        self.ocm.logLevel = .debug
        self.ocm.newContentsAvailableView = NewContentView()
        self.ocm.videoEventDelegate = self
        self.ocm.thumbnailEnabled = false
        self.ocm.customBehaviourDelegate = self
        
        let backgroundImage = UIImage(named: "rectangle8")
        let noContentView = NoContentViewDefault()
        noContentView.backgroundImage = backgroundImage
        noContentView.title = "Pardon!"
        noContentView.subtitle = "Il n'a pas de jet de contenu"
        self.ocm.noContentView = noContentView

        let errorView = ErrorViewDefault()
        errorView.backgroundImage = backgroundImage
        errorView.title = "Ups!"
        errorView.subtitle = "Nous avons une erreur"
        errorView.buttonTitle = "RECOMMENCEZ"
        self.ocm.errorView = errorView

        let loadingView = LoadingViewDefault()
        loadingView.title = "Chargement"
        loadingView.backgroundImage = backgroundImage
        self.ocm.loadingView = loadingView
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.ocm.backgroundSessionCompletionHandler = appDelegate.backgroundSessionCompletionHandler
        }
        self.customize()
        self.addProviders()
        self.ocm.businessUnit = "oat-it"
        self.ocm.offlineSupportConfig = OfflineSupportConfig(cacheSectionLimit: 10, cacheElementsPerSectionLimit: 6, cacheFirstSectionLimit: 12)        
        self.startOrchextra()
        
        self.perform(#selector(hideSplashOrx), with: self, afterDelay: 1.0)
    }
    
    // MARK: - Orchextra
    
    func startOrchextra() {
        self.ocm.orchextraHost = self.appController.orchextraHost
        
        self.ocm.start(apiKey: self.appController.orchextraApiKey,
                       apiSecret: self.appController.orchextraApiSecret) { result in

                        switch result {
                        case .success:
                            self.session.saveORX(apikey: self.appController.orchextraApiKey,
                                            apisecret: self.appController.orchextraApiSecret)
                            self.ocm.loadMenus()
                        case .error:
                            self.showCredentialsErrorMessage()
                        }
        }
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.appController.settings()
    }
    
    func showCredentialsErrorMessage() {
        let alert = Alert(
            title: "Credentials are not correct",
            message: "Apikey and Apisecret are invalid")
        alert.addCancelButton("Ok") { _ in
            self.restartOrx()
        }
        alert.show()
    }
    
    func restartOrx() {
        if let credentials = self.session.loadORXCredentials() {
            self.appController.orchextraApiKey = credentials.apikey
            self.appController.orchextraApiSecret = credentials.apisecret
        }
        self.startOrchextra()
        
    }

    // MARK: - Setup
    
    func addProviders() {
        let providers = Providers()
        providers.vimeo = VimeoProvider(accessToken: "2c13877fe3e6d0d8349482fb38fdbb88")
        self.ocm.providers = providers
    }
    
    func customize() {
        let styles = Styles()
        styles.primaryColor = UIColor(fromHexString: "#EB0853")
        styles.placeholderImage = #imageLiteral(resourceName: "thumbnail")
        styles.primaryColor = .darkGray
        self.ocm.styles = styles
        
        let navigationBarStyles = ContentNavigationBarStyles()
        navigationBarStyles.type = .navigationBar
        navigationBarStyles.barBackgroundImage = #imageLiteral(resourceName: "navigation_bar_background")
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
        self.pagesContainer.delegate = self
    }
    
    @objc func hideSplashOrx() {
        UIView.animate(withDuration: 0.5) {
            self.splashOrx.alpha = 0
        }
    }

    // MARK: - Private methods
    
    fileprivate func showSection(atPage page: Int) {
        guard page < self.menu.count else { return }
        let currentSection = self.menu[page]
        
        currentSection.openAction { action in
            if let action = action {
                self.pagesContainer.show(action, atIndex: page)
            }
        }
    }
    
    fileprivate func shouldLoadNextPage() -> Bool {
        let pageOffset = self.pagesContainer.contentOffset.x / self.pagesContainer.frame.size.width
        return pageOffset == round(pageOffset)
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
    }
    
    func contentRequiresUserAuthentication(_ completion: @escaping () -> Void) {
        OCM.shared.didLogin(with: "any_user_ID")
        completion()
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
        case .unsupportedVersionError:
            message = "Su dispositivo no es compatible con passbook"
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
            self.sectionsMenu.load(sections: menu.sections, contentScroll: self.pagesContainer)
            self.pagesContainer.prepare(forNumberOfPages: menu.sections.count, viewController: self)
            self.showSection(atPage: 0)
            break
        }
    }
    
    func show(section index: Int) {
        self.sectionsMenu.navigate(toSectionIndex: 0)
    }
    
    func federatedAuthentication(_ federated: [String: Any], completion: @escaping ([String: Any]?) -> Void) {
        LogInfo("Needs federated authentication")
        completion(["sso_token": "U2FsdGVkX1+zsyT1ULUqZZoAd/AANGnkQExYsAnzFlY5/Ff/BCkaSSuhR0/xvy0e"])
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.sectionsMenu.contentScrollViewDidEndDecelerating()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.sectionsMenu.contentScrollViewWillEndDragging()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.presentedViewController != nil { LogWarn("presentedViewController is nil"); return }
        self.sectionsMenu.contentDidScroll(to: scrollView.frame.origin.x)
        let appearingPage = Int(ceil((scrollView.contentOffset.x) / scrollView.frame.size.width))
        
        guard appearingPage < self.menu.count else { LogWarn("menu is nil"); return }
        self.showSection(atPage: appearingPage)
        
        if self.shouldLoadNextPage() {
            self.showSection(atPage: appearingPage + 1)
        }
    }
}

extension ViewController: OCMEventDelegate {
    
    func contentPreviewDidLoad(identifier: String, type: String) {
        LogInfo("identifier: \(identifier), type: \(type)")
    }
    
    func contentDidLoad(identifier: String, type: String) {
        LogInfo("identifier: \(identifier), type: \(type)")
    }
    
    func userDidShareContent(identifier: String, type: String) {
        LogInfo("identifier: \(identifier), type: \(type)")
    }
    
    func userDidOpenContent(identifier: String, type: String) {
        LogInfo("identifier: \(identifier), type: \(type)")
    }
    
    func videoDidLoad(identifier: String) {
        LogInfo("identifier: \(identifier)")
    }
    
    func sectionDidLoad(_ section: Section) {
        LogInfo("loaded section: \(section.name)")
    }
}

extension ViewController: OCMCustomBehaviourDelegate {
    
    
    func contentNeedsValidation(for customProperties: [String: Any], completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func contentNeedsCustomization(_ content: CustomizableContent, completion: @escaping (CustomizableContent) -> Void) {
        if content.viewType == .gridContent {
            if let requiredAuth = content.customProperties["requiredAuth"] as? String, requiredAuth == "logged" {
                content.customizations.append(.viewLayer(BlockedView().instantiate()))
                completion(content)
            }
        } else if content.viewType == .buttonElement {
            content.customizations.append(.disabled)
            completion(content)
        } else {
            completion(content)
        }
    }

}

extension UIViewController: OCMSDK.OCMVideoEventDelegate {
    
    public func videoDidStart(identifier: String) {
        print("Video Start: " + identifier)
    }
    
    public func videoDidStop(identifier: String) {
        print("Video Stop: " + identifier)
    }
    
    public func videoDidPause(identifier: String) {
        print("Video Pause: " + identifier)
    }
}

class LoadingView: StatusView {
    func
        instantiate() -> UIView {
        let loadingView = UIView(frame: CGRect.zero)
        loadingView.addSubviewWithAutolayout(UIImageView(image: #imageLiteral(resourceName: "loading")))
        loadingView.backgroundColor = .blue
        return loadingView
    }
}

class BlockedView: StatusView {
    func instantiate() -> UIView {
        let blockedView = UIView(frame: CGRect.zero)
        blockedView.addSubviewWithAutolayout(UIImageView(image: UIImage(named: "p")))
        
        let imageLocker = UIImageView(image: UIImage(named: "locker"))
        imageLocker.translatesAutoresizingMaskIntoConstraints = false
        imageLocker.center = blockedView.center
        blockedView.addSubview(imageLocker)
        blockedView.alpha = 0.8
        addConstraintsIcon(icon: imageLocker, view: blockedView)
        
        return blockedView
    }
    
    func addConstraintsIcon(icon: UIImageView, view: UIView) {
        
        let views = ["icon": icon]
        
        view.addConstraint(NSLayoutConstraint.init(
            item: icon,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0)
        )
        
        view.addConstraint(NSLayoutConstraint.init(
            item: icon,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0.0)
        )
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:[icon(65)]",
            options: .alignAllCenterY,
            metrics: nil,
            views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:[icon(65)]",
            options: .alignAllCenterX,
            metrics: nil,
            views: views))
    }
}

class NoContentView: StatusView {
    func instantiate() -> UIView {
        let loadingView = UIView(frame: CGRect.zero)
        loadingView.addSubviewWithAutolayout(UIImageView(image: #imageLiteral(resourceName: "DISCOVER MORE")))
        loadingView.backgroundColor = .gray
        return loadingView
    }
}

class NewContentView: StatusView {
    func instantiate() -> UIView {
        let newContentButton = UIButton()
        newContentButton.setTitle("NEW POST", for: .normal)
        newContentButton.setTitleColor(.blue, for: .normal)
        newContentButton.setImage(#imageLiteral(resourceName: "new_content_arrow"), for: .normal)
        newContentButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        newContentButton.backgroundColor = .white
        newContentButton.setCornerRadius(15)
        newContentButton.imageView?.tintColor = .blue
        newContentButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        newContentButton.layer.shadowColor = UIColor.black.cgColor
        newContentButton.layer.shadowRadius = 10.0
        newContentButton.layer.shadowOpacity = 0.5
        newContentButton.layer.masksToBounds = false
        newContentButton.isUserInteractionEnabled = false
        gig_constrain_height(newContentButton, 30)
        gig_constrain_width(newContentButton, 150)
        return newContentButton
    }
}

struct ViewMargin {
    var top: CGFloat?
    var bottom: CGFloat?
    var left: CGFloat?
    var right: CGFloat?
    
    static func zero() -> ViewMargin {
        return ViewMargin(top: 0, bottom: 0, left: 0, right: 0)
    }
    
    init(top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}

extension UIView {
    
    func addSubViewWithAutoLayout(view: UIView, withMargin margin: ViewMargin) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        self.applyMargin(margin, to: view)
    }
    
    private func applyMargin(_ margin: ViewMargin, to view: UIView) {
        if let top = margin.top {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: top)
            )
        }
        if let bottom = margin.bottom {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -bottom)
            )
        }
        if let left = margin.left {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: left)
            )
        }
        if let right = margin.right {
            self.addConstraint(
                NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -right)
            )
        }
    }
}
