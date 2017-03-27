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
    func cardsView(_ cardsView: CardsView, viewForCard card: Int) -> UIView?
}

protocol CardsViewDelegate: class {
    func cardsView(_ cardsView: CardsView, didSelectBottomOfCardAt index: Int)
    func cardsView(_ cardsView: CardsView, didSelectTopOfCardAt index: Int)
}

class CardsView: UIView {
    
    // MARK: - Public attributes
    
    weak var delegate: CardsViewDelegate?
    weak var dataSource: CardsViewDataSource?
    
    // MARK: - Private attributes
    
    fileprivate var currentCard: Int = 0
    fileprivate var loadedCards: [Int: UIView] = [:]
    
    // MARK: - Public methods
    
    func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.setupView()
        self.currentCard = 0
        loadCurrentCard()
        loadNextCard()
    }
    
    // MARK: - Actions
    
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Fisrt check the gesture direction
        let velocity = gestureRecognizer.velocity(in: self)
        if velocity.y > 0 {
            // When we scroll down
            guard
                let view = previousCardView() as? CardView,
                let topMargin = self.topMargin(of: view),
                let bottomMargin = self.bottomMargin(of: view)
            else {
                return
            }
            if !self.subviews.contains(view) {
                print("Add previous view")
                self.loadPreviousCard()
            }
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self)
                topMargin.constant += translation.y
                bottomMargin.constant += translation.y
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            }
            if gestureRecognizer.state == .ended {
                if topMargin.constant <= -(view.frame.size.height / 2) {
                    topMargin.constant = -view.frame.size.height
                    bottomMargin.constant = -view.frame.size.height
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.layoutIfNeeded()
                    },
                        completion: { finished  in
                            if finished {
                                self.currentCard -= 1
                                // view.removeFromSuperview()
                            }
                    }
                    )
                } else {
                    topMargin.constant = 0
                    bottomMargin.constant = 0
                    UIView.animate(withDuration: 0.3) {
                        self.layoutIfNeeded()
                    }
                }
            }
        } else {
            // When we scroll to top
            guard
                let view = currentCardView() as? CardView,
                let topMargin = self.topMargin(of: view),
                let bottomMargin = self.bottomMargin(of: view)
            else {
                return
            }
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self)
                topMargin.constant += translation.y
                bottomMargin.constant += translation.y
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
            }
            if gestureRecognizer.state == .ended {
                if topMargin.constant <= -(view.frame.size.height / 2) {
                    topMargin.constant = -view.frame.size.height
                    bottomMargin.constant = -view.frame.size.height
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self.layoutIfNeeded()
                        },
                        completion: { finished  in
                            if finished {
                                self.currentCard += 1
                                // view.removeFromSuperview()
                            }
                        }
                    )
                } else {
                    topMargin.constant = 0
                    bottomMargin.constant = 0
                    UIView.animate(withDuration: 0.3) {
                        self.layoutIfNeeded()
                    }
                }
            }
        }
    }
}

private extension CardsView {
    
    func setupView() {
        // Add pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(panGesture)
    }
    
    func loadCurrentCard() {
        Log("Loading current card")
        guard let view = loadView(at: self.currentCard) else { return }
        self.addSubViewWithAutoLayout(
            view: view,
            withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0)
        )
    }
    
    func loadNextCard() {
        Log("Loading next card")
        guard
            let view = loadView(at: self.currentCard + 1),
            let last = self.subviews.last
        else {
            return
        }
        self.insertSubviewWithAutoLayout(
            view,
            withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0),
            belowSubview: last
        )
    }
    
    func loadPreviousCard() {
        Log("Loading previous card")
        guard let view = self.previousCardView() else { return }
        self.addSubViewWithAutoLayout(
            view: view,
            withMargin: ViewMargin(top: -self.frame.size.height, bottom: 0, left: 0, right: 0)
        )
    }
    
    func loadView(at index: Int) -> UIView? {
        guard let dataSource = self.dataSource else { return nil }
        let cards = dataSource.cardsViewNumberOfCards(self)
        if (index + 1) > cards {
            LogWarn("There is no more cards to load")
        } else {
            if let card = self.loadedCards[index] {
                return card
            } else {
                guard let card = dataSource.cardsView(self, viewForCard: index) else { return nil }
                self.loadedCards[index] = card
                return card
            }
        }
        return nil
    }
    
    func currentCardView() -> UIView? {
        return self.subviews.last
    }
    
    func previousCardView() -> UIView? {
        if let view = self.loadedCards[self.currentCard - 1] {
            return view
        }
        return nil
    }
}

extension UIView {
    
    func topMargin(of view: UIView) -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            ($0.firstItem as? NSObject) == view && $0.firstAttribute == .top
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
    
    func bottomMargin(of view: UIView) -> NSLayoutConstraint? {
        let index = self.constraints.index(where: {
            ($0.firstItem as? NSObject) == view && $0.firstAttribute == .bottom
        })
        guard let constraintIndex = index else { return nil }
        return self.constraints[constraintIndex]
    }
}
