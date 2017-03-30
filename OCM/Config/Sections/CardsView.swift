//
//  CardsView.swift
//  OCM
//
//  Created by José Estela on 21/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

enum CardsViewScrollDirection {
    case none
    case top
    case bottom
}

protocol CardsViewDataSource: class {
    func cardsViewNumberOfCards(_ cardsView: CardsView) -> Int
    func cardsView(_ cardsView: CardsView, viewForCard card: Int) -> UIView
}

class CardsView: UIView {
    
    // MARK: - Public attributes
    
    weak var dataSource: CardsViewDataSource?
    
    // MARK: - Private attributes
    
    fileprivate let maxCardsInMemory = 3
    fileprivate let scrollAnimationDuration: TimeInterval = 0.4
    fileprivate let maxPercentageOfScreenToChangePage: CGFloat = 0.3
    
    fileprivate var currentCard: Int = 0
    fileprivate var loadedCards: [Int: UIView] = [:]
    fileprivate var scrollDirection: CardsViewScrollDirection = .none
    
    // MARK: - Public methods
    
    func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.setupView()
        self.currentCard = 0
        self.loadCurrentCard()
        self.loadNextCard()
    }
}

private extension CardsView {
    
    // MARK: - Actions
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Fisrt check the gesture direction
        let velocity = gestureRecognizer.velocity(in: self)
        if velocity.y > 0 {
            self.downMovement(with: gestureRecognizer)
        } else {
            self.upMovement(with: gestureRecognizer)
        }
    }
    
    // MARK: - Setup view
    
    func setupView() {
        // Add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Card load methods
    
    func loadCurrentCard() {
        guard let view = self.currentCardView() else { return }
        self.addSubViewWithAutoLayout(
            view: view,
            withMargin: ViewMargin(top: 0, left: 0, right: 0)
        )
    }
    
    func loadNextCard() {
        guard
            let view = self.nextCardView(),
            let currentCard = self.loadedCards[self.currentCard],
            let index = self.subviews.index(of: currentCard)
        else {
            return
        }
        self.insertSubviewWithAutoLayout(
            view,
            withMargin: ViewMargin(top: 0, left: 0, right: 0),
            belowSubview: self.subviews[index]
        )
    }
    
    func loadPreviousCard() {
        guard let view = self.previousCardView() else { return }
        self.addSubViewWithAutoLayout(
            view: view,
            withMargin: ViewMargin(top: -self.frame.size.height, left: 0, right: 0)
        )
    }
    
    func loadCardView(at index: Int) -> UIView? {
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
    
    // MARK: - Card return methods
    
    func currentCardView() -> UIView? {
        guard let view = loadCardView(at: self.currentCard) else { return nil }
        guard let index = self.subviews.index(of: view) else { return view }
        return self.subviews[index]
    }
    
    func previousCardView() -> UIView? {
        return loadCardView(at: self.currentCard - 1)
    }
    
    func nextCardView() -> UIView? {
        return loadCardView(at: self.currentCard + 1)
    }
    
    // MARK: - Up movement methods
    
    func upMovement(with gestureRecognizer: UIPanGestureRecognizer) {
        // When we scroll to top
        if self.scrollDirection == .none || self.scrollDirection == .top {
            self.scrollDirection = .top
            switch gestureRecognizer.state {
            case .began, .changed:
                self.upMovementContinue(with: gestureRecognizer)
            case .ended:
                self.upMovementEnd()
            default:
                break
            }
        } else if gestureRecognizer.state == .ended {
            self.downMovementEnd()
        } else {
            self.downMovementContinue(with: gestureRecognizer)
        }
    }
    
    func upMovementBegin() {
        // Nothing to do here right now
    }
    
    func upMovementContinue(with gestureRecognizer: UIPanGestureRecognizer) {
        guard
            let view = self.currentCardView() as? CardView,
            let topMargin = self.topMargin(of: view)
        else {
            return
        }
        let translation = gestureRecognizer.translation(in: self)
        topMargin.constant += translation.y
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    func upMovementEnd() {
        self.scrollDirection = .none
        guard
            let view = self.currentCardView() as? CardView,
            let topMargin = self.topMargin(of: view)
        else {
            return
        }
        if abs(topMargin.constant) >= abs(view.frame.size.height * maxPercentageOfScreenToChangePage) {
            topMargin.constant = -view.frame.size.height
            UIView.animate(
                withDuration: scrollAnimationDuration,
                animations: {
                    self.layoutIfNeeded()
                },
                completion: { finished  in
                    if finished {
                        self.currentCard += 1
                        view.removeFromSuperview()
                        self.loadNextCard()
                    }
                }
            )
        } else {
            topMargin.constant = 0
            UIView.animate(withDuration: scrollAnimationDuration) {
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Down movement methods
    
    func downMovement(with gestureRecognizer: UIPanGestureRecognizer) {
        // When we scroll down
        if self.scrollDirection == .none || self.scrollDirection == .bottom {
            self.scrollDirection = .bottom
            switch gestureRecognizer.state {
            case .began:
                self.downMovementBegin()
            case .changed:
                self.downMovementContinue(with: gestureRecognizer)
            case .ended:
                self.downMovementEnd()
            default:
                break
            }
        } else if gestureRecognizer.state == .ended {
            self.upMovementEnd()
        } else {
            self.upMovementContinue(with: gestureRecognizer)
        }
    }
    
    func downMovementBegin() {
        guard
            let view = self.previousCardView() as? CardView
        else {
            return
        }
        if !self.subviews.contains(view) {
            self.loadPreviousCard()
        }
    }
    
    func downMovementContinue(with gestureRecognizer: UIPanGestureRecognizer) {
        guard
            let view = self.previousCardView() as? CardView,
            let topMargin = self.topMargin(of: view)
        else {
            return
        }
        let translation = gestureRecognizer.translation(in: self)
        topMargin.constant += translation.y
        gestureRecognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    func downMovementEnd() {
        self.scrollDirection = .none
        guard
            let view = self.previousCardView() as? CardView,
            let topMargin = self.topMargin(of: view)
        else {
            return
        }
        if abs(topMargin.constant) >= abs(view.frame.size.height * maxPercentageOfScreenToChangePage) {
            topMargin.constant = 0
            UIView.animate(
                withDuration: scrollAnimationDuration,
                animations: {
                    self.layoutIfNeeded()
                },
                completion: { finished  in
                    if finished {
                        self.currentCard -= 1
                    }
                }
            )
        } else {
            topMargin.constant = -view.frame.size.height
            UIView.animate(withDuration: scrollAnimationDuration) {
                self.layoutIfNeeded()
            }
        }
        
    }
    
    // MARK: - Helpers
    
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

private extension Int {
    
    func diff(with value: Int) -> Int {
        return abs(value - self)
    }
}

private extension UIView {
    
    func topMargin(of view: UIView) -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            ($0.firstItem as? NSObject) == view && $0.firstAttribute == .top
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
}
