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

protocol CardsViewDelegate: class {
    func cardsView(_ cardsView: CardsView, didSelectBottomCardAt index: Int)
    func cardsView(_ cardsView: CardsView, didSelectTopCardAt index: Int)
}

class CardsView: UIView {
    
    // MARK: - Public attributes
    
    weak var delegate: CardsViewDelegate?
    weak var dataSource: CardsViewDataSource?
    
    // MARK: - Private attributes
    
    fileprivate var currentCard: Int = 0
    
    // MARK: - Public methods
    
    func reloadData() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        self.setupView()
        self.currentCard = 0
        self.showView(at: self.currentCard)
    }
    
    // MARK: - Actions
    
    @IBAction fileprivate func bottomTap(sender: UIButton) {
        self.delegate?.cardsView(self, didSelectBottomCardAt: self.currentCard)
        self.showNextView(animated: true)
    }
    
    @IBAction fileprivate func topTap(sender: UIButton) {
        self.delegate?.cardsView(self, didSelectBottomCardAt: self.currentCard)
        self.showPreviousView(animated: true)
    }
}

private extension CardsView {
    
    func showNextView(animated: Bool) {
        guard
            let dataSource = self.dataSource
            else {
                return
        }
        let cards = dataSource.cardsViewNumberOfCards(self)
        if self.currentCard > cards {
            Log("There isn't any more cards")
        } else {
            self.currentCard += 1
            self.showView(at: self.currentCard, animated: animated)
        }
    }
    
    func showPreviousView(animated: Bool) {
        if self.currentCard > 0 {
            self.dismissCurrentView()
            self.currentCard -= 1
        }
    }
    
    func showView(at index: Int, animated: Bool = false) {
        guard
            let dataSource = self.dataSource
        else {
            return
        }
        let view = dataSource.cardsView(self, viewForCard: index)
        let insideView = UIView()
        insideView.layer.masksToBounds = true
        insideView.addSubview(view)
        self.addSubViewWithAutoLayout(
            view: insideView,
            withMargin: ViewMargin(top: animated ? self.frame.size.height : 0, bottom: 0, left: 0, right: 0),
            at: self.subviews.count - 2
        )
        insideView.backgroundColor = .white
        view.centerXAnchor.constraint(equalTo: insideView.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: insideView.centerYAnchor).isActive = true
        view.backgroundColor = .clear
        self.layoutIfNeeded()
        if animated {
            for constraint in self.constraints {
                if let item = constraint.firstItem as? NSObject {
                    if item == insideView && constraint.firstAttribute == .top {
                        constraint.constant = 0.0
                        UIView.animate(withDuration: 0.4) {
                            self.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
    
    func dismissCurrentView() {
        if self.subviews.indices.contains(self.currentCard) {
            let subView = self.subviews[self.currentCard]
            for constraint in self.constraints {
                if let item = constraint.firstItem as? NSObject {
                    if item == subView && constraint.firstAttribute == .top {
                        constraint.constant = self.frame.size.height
                        UIView.animate(
                            withDuration: 0.4,
                            animations: {
                                self.layoutIfNeeded()
                            }
                        ) { finished in
                            if finished {
                                subView.removeFromSuperview()
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func setupView() {
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
}
