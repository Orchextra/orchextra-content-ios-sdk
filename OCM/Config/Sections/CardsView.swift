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
        // Load two first views
        self.loadView(at: 0)
        // Show the first view
        self.currentCard = 0
        self.showView(at: self.currentCard)
    }
    
    // MARK: - Actions
    
    @IBAction fileprivate func bottomTap(sender: UIButton) {
        self.delegate?.cardsView(self, didSelectBottomOfCardAt: self.currentCard)
        self.showNextView(animated: true)
    }
    
    @IBAction fileprivate func topTap(sender: UIButton) {
        self.delegate?.cardsView(self, didSelectBottomOfCardAt: self.currentCard)
        self.showPreviousView(animated: true)
    }
}

private extension CardsView {
    
    func setupView() {
        // Add bottom button to change of card
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
                constant: 50.0
            )
        )
        bottomButton.backgroundColor = .clear
        // Add top button to change of card
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
                constant: 50.0
            )
        )
        topButton.backgroundColor = .clear
    }
    
    func loadView(at index: Int) {
        guard let dataSource = self.dataSource else { return }
        let cards = dataSource.cardsViewNumberOfCards(self)
        if index + 1 > cards {
            LogWarn("There is no more cards to load")
        } else {
            if let card = self.loadedCards[index] {
                let _ = self.addCard(view: card, at: index)
            } else {
                guard let card = dataSource.cardsView(self, viewForCard: index) else { return }
                self.loadedCards[index] = self.addCard(view: card, at: index)
            }
        }
    }
    
    func addCard(view: UIView, at index: Int) -> UIView {
        if index == 0 {
            self.addSubViewWithAutoLayout(
                view: view,
                withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0),
                at: self.subviews.count - 2
            )
            return view
        } else {
            // Create an aux scrollview that will be contain a view with clear color and our cardview
            let scrollView = UIScrollView()
            scrollView.backgroundColor = .clear
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.delegate = self
            self.addSubViewWithAutoLayout(
                view: scrollView,
                withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0),
                at: self.subviews.count - 2
            )
            
            let topView = UIView()
            topView.backgroundColor = .clear
            topView.setLayoutHeight(self.frame.size.height)
            topView.setLayoutWidth(self.frame.size.width)
            
            view.setLayoutHeight(self.frame.size.height)
            view.setLayoutWidth(self.frame.size.width)
            
            let stackView = UIStackView(arrangedSubviews: [
                topView,
                view
                ])
            stackView.axis = .vertical
            
            scrollView.addSubViewWithAutoLayout(
                view: stackView,
                withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0)
            )
            self.layoutIfNeeded()
            return scrollView
        }
    }
    
    func showNextView(animated: Bool) {
        guard let dataSource = self.dataSource else { return }
        let cards = dataSource.cardsViewNumberOfCards(self)
        if (self.currentCard + 1) >= cards {
            Log("No more cards to show")
        } else {
            self.currentCard += 1
            self.showView(at: self.currentCard, animated: animated)
        }
    }
    
    func showPreviousView(animated: Bool) {
        if self.currentCard > 0 {
            self.dismissCurrentView(animated: animated)
            self.currentCard -= 1
        }
    }
    
    func showView(at index: Int, animated: Bool = false) {
        // load view of the given index
        self.loadView(at: index + 1)
        guard
            let view = self.loadedCards[index] as? UIScrollView
        else {
            return
        }
        view.scrollToBottom()
    }
    
    func dismissCurrentView(animated: Bool) {
        if self.subviews.indices.contains(self.currentCard) {
            let subView = self.subviews[self.currentCard]
            if animated {
                self.animateView(
                    view: subView,
                    withDuration: 0.4,
                    toTopFrame: self.frame.size.height
                ) {
                    subView.removeFromSuperview()
                }
            } else {
                subView.removeFromSuperview()
            }
        }
    }

    func animateView(view: UIView, withDuration duration: TimeInterval, toTopFrame top: CGFloat, completion: (() -> Void)?) {
        let index = self.constraints.index(where: {
            ($0.firstItem as? NSObject) == view && $0.firstAttribute == .top
        })
        guard let constraintIndex = index else { return }
        self.constraints[constraintIndex].constant = top
        UIView.animate(
            withDuration: duration,
            animations: {
                self.layoutIfNeeded()
        }
        ) { finished in
            if finished {
                completion?()
            }
        }
    }
}

extension CardsView: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.currentPage == 1 {
            self.currentCard += 1
            self.loadView(at: self.currentCard + 1)
        }
    }
}

extension UIScrollView {
    var currentPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.height)) / self.frame.height) + 1
    }
}
