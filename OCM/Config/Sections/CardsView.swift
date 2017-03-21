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
    
    private var currentCard: Int = 0
    
    // MARK: - Outlets
    
    fileprivate var scrollView: UIScrollView = UIScrollView()
    fileprivate var stackView: UIStackView = UIStackView()
    
    // MARK: - Public methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func reloadData() {
        self.stackView.removeSubviews()
        guard
            let dataSource = self.dataSource
        else {
            return
        }
        let cards = dataSource.cardsViewNumberOfCards(self)
        for i in 0...(cards - 1) {
            let insideView = UIView()
            let view = dataSource.cardsView(self, viewForCard: i)
            insideView.backgroundColor = .clear
            insideView.widthAnchor.constraint(equalToConstant: self.frame.size.width).isActive = true
            insideView.heightAnchor.constraint(equalToConstant: self.frame.size.height).isActive = true
            insideView.layer.masksToBounds = true
            insideView.addSubview(view)
            view.centerXAnchor.constraint(equalTo: insideView.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: insideView.centerYAnchor).isActive = true
            view.backgroundColor = .clear
            self.stackView.addArrangedSubview(insideView)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func bottomTap(sender: UIButton) {
        self.delegate?.cardsView(self, didSelectBottomCardAt: self.currentCard)
    }
    
    @IBAction private func topTap(sender: UIButton) {
        self.delegate?.cardsView(self, didSelectBottomCardAt: self.currentCard)
    }
}

private extension CardsView {
    
    func setupView() {
        self.scrollView.isScrollEnabled = true
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.stackView.axis = .vertical
        self.addSubviewWithAutolayout(self.scrollView)
        self.scrollView.addSubviewWithAutolayout(self.stackView)
        /*
        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.stackView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.stackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
         */
    }
}
