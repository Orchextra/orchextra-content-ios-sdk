//
//  SearchVC.swift
//  OCM
//
//  Created by José Estela on 21/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class SearchVC: UIViewController, SearchUI {
    
    // MARK: - Attributtes
    
    var presenter: SearchPresenter?
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.viewDidLoad()
    }
}
