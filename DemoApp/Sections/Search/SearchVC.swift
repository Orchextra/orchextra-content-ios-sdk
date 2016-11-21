//
//  SearchVC.swift
//  OCM
//
//  Created by Sergio López on 15/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import OCMSDK

class SearchVC: UIViewController {

    @IBOutlet weak var searchContainer: UIView!
    
    var ocmSearch: OrchextraViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let searchVC = OCM.shared.searchViewController()
        self.ocmSearch = searchVC
        if let searchVC = searchVC {
            self.addChildViewController(searchVC)
            self.searchContainer.addSubview(searchVC.view)
            searchVC.didMove(toParentViewController: self)
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            self.ocmSearch?.search(byString: text)
        } else {
            self.ocmSearch?.showInitialContent()
        }
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.text != nil {
            self.ocmSearch?.showInitialContent()
        }
        return true
    }
}
