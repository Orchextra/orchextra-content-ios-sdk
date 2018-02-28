//
//  CardsVC.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class CardsVC: OCMViewController, MainContentComponentUI, CardsUI {
    
    // MARK: - Attributtes
    
    var presenter: CardsPresenter?
    
    // MARK: - Outlets
    
    @IBOutlet weak var cardsView: CardsView!
    
    // MARK: - Private attributes
    
    fileprivate var cards: [Card] = []
    
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
    
    func showCards(cards: [Card]) {
        self.cards = cards
        self.cardsView.reloadData()
    }
    
    // MARK: - MainContentComponentUI
    
    var container: MainContentContainerUI?
    var returnButtonIcon: UIImage?
        
    func titleForComponent() -> String? {
        return nil
    }
    
    func containerScrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

// MARK: - Instantiable

extension CardsVC: Instantiable {
    
    static var storyboard = "OCM"
    static var identifier =  "CardsVC"
}

// MARK: - CardsViewDataSource

extension CardsVC: CardsViewDataSource {
    
    func cardsViewNumberOfCards(_ cardsView: CardsView) -> Int {
        return self.cards.count
    }
    
    func cardsView(_ cardsView: CardsView, viewForCard card: Int) -> UIView {
        return CardView.from(card: self.cards[card]) ?? UIView()
    }
}
