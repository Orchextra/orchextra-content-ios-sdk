//
//  CardsVC.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class CardsVC: OrchextraViewController, CardsUI {
    
    // MARK: - Attributtes
    
    var presenter: CardsPresenter?
    
    // MARK: - Outlets
    
    @IBOutlet weak var cardsView: CardsView!
    
    // MARK: - Private attributes
    
    fileprivate var elements: [UIView] = []
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardsView.dataSource = self
        self.presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewDidAppear()
    }
    
    // MARK: - CardsUI
    
    func showElemenst(elements: [Element]) {
        for element in elements {
            for view in element.render() {
                self.elements.append(view)
            }
        }
        self.cardsView.reloadData()
    }
}

extension CardsVC: Instantiable {
    
    // MARK: - Instantiable
    
    public static func storyboard() -> String {
        return "OCM"
    }
    
    public static func identifier() -> String? {
        return "CardsVC"
    }
}

extension CardsVC: CardsViewDataSource {
    
    func cardsViewNumberOfCards(_ cardsView: CardsView) -> Int {
        return self.elements.count
    }
    
    func cardsView(_ cardsView: CardsView, viewForCard card: Int) -> UIView {
        return self.elements[card]
    }
}
