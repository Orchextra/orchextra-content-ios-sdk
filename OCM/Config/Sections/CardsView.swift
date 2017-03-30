//
//  CardsView.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

protocol CardsViewDataSource: class {
    func cardsViewNumberOfCards(_ cardsView: CardsView) -> Int
    func cardsView(_ cardsView: CardsView, viewForCard card: Int) -> UIView
}

class CardsView: UIView {
    
    // MARK: - Public attributes
    
    weak var dataSource: CardsViewDataSource?
    
    // MARK: - Private attributes
    
    fileprivate let maxCardsInMemory = 4
    fileprivate var currentCard: Int = 0
    fileprivate var loadedCards: [Int: UIView] = [:]
    fileprivate var currentScrollPage: Int = 0
    fileprivate var scrollView: UIScrollView = UIScrollView()
    fileprivate var transparentView: UIView = UIView()
    
    // MARK: - Public methods
    
    func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.currentCard = 0
        self.loadCurrentPreviousAndNextCard()
    }
    
    // MARK: - Actions
    
    @objc fileprivate func bottomTap(sender: UIButton) {
        self.showNextView(animated: true)
    }
    
    @objc fileprivate func topTap(sender: UIButton) {
        self.showPreviousView(animated: true)
    }
}

private extension CardsView {
    
    /// This method load the current card and add it to subView. Then, it create a scrollView with next and previous card and add it infront of the current card.
    ///
    ///        2)
    ///         ___
    /// 1)     | P |
    ///  ___   |__ |
    /// | C |  | X |
    /// |___|  |___|
    ///        | N |
    ///        |___|
    ///
    /// Here there is a representation of what it creates:
    ///
    /// * C -> Current card view
    /// * P -> Previous card view
    /// * X -> Clear view to show the current card behind
    /// * N -> Next card view
    ///
    /// 1) The first view is the current card (UIView).
    /// 2) The second view is a scrollView with a StackView Inside and the views described.
    ///
    func loadCurrentPreviousAndNextCard() {
        guard let currentCardView = loadView(at: self.currentCard) else { return }
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        self.addSubViewWithAutoLayout(view: currentCardView, withMargin: .zero())
        
        self.configureScrollView()
        self.configureTransparentView()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        var hasPrev = false
        var hasNext = false
        
        // Add a previous card (if exist)
        if let prev = loadView(at: self.currentCard - 1) {
            hasPrev = true
            prev.setLayoutHeight(self.frame.size.height)
            prev.setLayoutWidth(self.frame.size.width)
            stackView.addArrangedSubview(prev)
        }
        
        // Add a transparentView view to stack (to can see the current card behind)
        stackView.addArrangedSubview(self.transparentView)
        
        // Add next card (if exist)
        if let next = loadView(at: self.currentCard + 1) {
            hasNext = true
            next.setLayoutHeight(self.frame.size.height)
            next.setLayoutWidth(self.frame.size.width)
            stackView.addArrangedSubview(next)
        }
        self.scrollView.addSubViewWithAutoLayout(view: stackView, withMargin: .zero())
        self.addSubViewWithAutoLayout(view: self.scrollView, withMargin: .zero())
        
        self.layoutIfNeeded()
        
        // If there is prev and next or only prev card, scroll to second page (transparent page) to see the card behind
        if (hasNext && hasPrev) || (hasPrev && !hasNext) {
            self.currentScrollPage = 1
            self.scrollView.scrollRectToVisible(transparentView.frame, animated: false)
        }
        
        self.addButtonsToChangeOfCard()
    }
    
    func configureScrollView() {
        self.scrollView = UIScrollView()
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.bounces = false
        self.scrollView.delegate = self
        self.currentScrollPage = 0
    }
    
    func configureTransparentView() {
        self.transparentView = UIView()
        self.transparentView.backgroundColor = .clear
        self.transparentView.setLayoutHeight(self.frame.size.height)
        self.transparentView.setLayoutWidth(self.frame.size.width)
    }
    
    func addButtonsToChangeOfCard() {
        let bottomButton = UIButton()
        bottomButton.addTarget(self, action: #selector(bottomTap(sender:)), for: .touchUpInside)
        self.addSubViewWithAutoLayout(view: bottomButton, withMargin: ViewMargin(bottom: 0, left: 0, right: 0))
        bottomButton.addConstraint(
            NSLayoutConstraint(
                item: bottomButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: 90.0
            )
        )
        bottomButton.backgroundColor = .clear
        
        let topButton = UIButton()
        topButton.addTarget(self, action: #selector(topTap(sender:)), for: .touchUpInside)
        self.addSubViewWithAutoLayout(view: topButton, withMargin: ViewMargin(top: 0, left: 0, right: 0))
        topButton.addConstraint(
            NSLayoutConstraint(
                item: topButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: 90.0
            )
        )
        topButton.backgroundColor = .clear
    }
    
    func showNextView(animated: Bool) {
        let scrollPages = self.scrollView.numberOfPages
        let yPosition = CGFloat(scrollPages - 1) * self.frame.size.height
        self.scrollView.scrollRectToVisible(CGRect(x: 0, y: yPosition, width: self.frame.size.width, height: self.frame.size.height), animated: true)
    }
    
    func showPreviousView(animated: Bool) {
        self.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height), animated: true)
    }
    
    func loadView(at index: Int) -> UIView? {
        guard let dataSource = self.dataSource else { return nil }
        let cards = dataSource.cardsViewNumberOfCards(self)
        if index < cards && index >= 0 {
            if let card = self.loadedCards[index] {
                return card
            } else {
                let card = dataSource.cardsView(self, viewForCard: index)
                self.loadedCards[index] = card
                self.checkCacheOfLoadedCards(withCurrentAdded: index)
                return card
            }
        }
        return nil
    }
    
    func checkIfNeedToChangePage() {
        let scrollPage = Int((self.scrollView.contentOffset.y + (0.5 * self.scrollView.frame.size.height)) / self.scrollView.frame.height)
        if self.currentScrollPage != scrollPage {
            self.currentScrollPage = scrollPage
            if scrollPage == (self.scrollView.numberOfPages - 1) {
                self.currentCard += 1
                self.loadCurrentPreviousAndNextCard()
            } else if scrollPage == 0 {
                self.currentCard -= 1
                self.loadCurrentPreviousAndNextCard()
            }
        }
    }
    
    func checkCacheOfLoadedCards(withCurrentAdded added: Int) {
        if self.loadedCards.count > self.maxCardsInMemory {
            let newLoadedCards = self.loadedCards.filter({ $0.key.diff(with: added) <= (self.maxCardsInMemory - 1) })
            self.loadedCards = [:]
            for card in newLoadedCards {
                self.loadedCards[card.key] =  card.value
            }
        }
    }
    
}

extension CardsView: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        checkIfNeedToChangePage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkIfNeedToChangePage()
    }
}

extension Int {
    func diff(with value: Int) -> Int {
        return abs(value - self)
    }
}

extension UIScrollView {
    var numberOfPages: Int {
        return Int(self.contentSize.height / self.frame.size.height)
    }
}
