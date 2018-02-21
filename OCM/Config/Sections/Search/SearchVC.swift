//
//  SearchVC.swift
//  OCM
//
//  Created by José Estela on 21/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

public class SearchVC: UIViewController, SearchUI {
    
    // MARK: - Attributtes
    
    var presenter: SearchPresenter?
    
    // MARK: - View life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public func search(byString: String) {
        
    }
    
    public func showInitialContent() {
        // !!!
    }
}
