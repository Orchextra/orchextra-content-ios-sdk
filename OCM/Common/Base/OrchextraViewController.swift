//
//  OrchextraViewController.swift
//  OCM
//
//  Created by Sergio López on 26/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

public class OrchextraViewController: UIViewController {
    
    private var spinner: Spinable?
    var bannerView: BannerView?
    
    // MARK: - PUBLIC
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public func filter(byTags: [String]) {
    }
    
    public func search(byString: String) {
    }
    
    public func showInitialContent() {
    }
    
    func showSpinner(show: Bool) {        
        if self.spinner == nil {
            self.spinner = Spinable(view: self.view)
        }
        self.spinner?.showSpinner(show: show)
    }
    
    func showBannerAlert(_ message: String) {
        guard let banner = self.bannerView, banner.isVisible else {
            self.bannerView = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.width(), height: 50)), message: message)
            self.bannerView?.show(in: self.view, hideIn: 1.5)
            return
        }
    }
}
