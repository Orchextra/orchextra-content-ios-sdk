//
//  CardView.swift
//  OCM
//
//  Created by José Estela on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class CardView: UIView {
    
    // MARK: - Private attributes
    
    fileprivate var cardComponents: [CardComponent] = []
    fileprivate var stackView: UIStackView?
    
    // MARK: - Instance method
    
    class func from(card: Card) -> CardView? {
        let cardView = CardView()
        cardView.stackView = UIStackView()
        cardView.stackView?.axis = .vertical
        cardView.stackView?.alignment = .center
        cardView.stackView?.distribution = .fill
        // Get the card components and add its to view
        guard let components = CardComponentsFactory.cardComponents(with: card) else { return nil }
        cardView.initializeCardView(with: components)
        return cardView
    }
}

private extension CardView {

    func initializeCardView(with components: [CardComponent]) {
        guard let stackView = self.stackView else { return }
        self.backgroundColor = .white
        var margin: CGFloat = 0
        switch components[0].type {
        case .text(text: _):
            margin = 120
        default:
            margin = 0
        }
        self.addSubViewWithAutoLayout(
            view: stackView,
            withMargin: ViewMargin(top: margin, bottom: 0, left: 0, right: 0)
        )
        
        for component in components {
            switch component.type {
            case .image(url: let imageUrl):
                self.addImage(from: imageUrl, withPercentage: component.percentage)
            case .text(text: let text):
                self.addText(text, withPercentage: component.percentage)
            }
        }
    }
    
    // MARK: - View methods
    
    func addImage(from url: URL, withPercentage percentage: Float) {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        let width: Int = Int(UIScreen.main.bounds.width)
        let height: Int = Int(UIScreen.main.bounds.height * CGFloat(percentage))
        let scaleFactor: Int = Int(UIScreen.main.scale)
        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: url.absoluteString,
            width: width,
            height: height,
            scaleFactor: scaleFactor
        )
        let urlAddptedToSize = urlSizeComposserWrapper.urlCompossed
        imageView.imageFromURL(urlString: urlAddptedToSize, placeholder: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLayoutWidth(CGFloat(width))
        imageView.setLayoutHeight(CGFloat(height) * CGFloat(percentage))
        self.stackView?.addArrangedSubview(imageView)
    }
    
    func addText(_ text: String, withPercentage percentage: Float) {
        let label = TopAlignedLabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.html = text
        label.setLayoutWidth(UIScreen.main.bounds.width * 0.9)
        label.setLayoutHeight(UIScreen.main.bounds.height * CGFloat(percentage))
        self.stackView?.addArrangedSubview(label)
    }
}
