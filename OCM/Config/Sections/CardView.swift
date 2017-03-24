//
//  CardView.swift
//  OCM
//
//  Created by José Estela on 23/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

struct CardComponent {
    let type: CardComponentType
    let percent: Float
}

enum CardComponentType {
    case image(url: URL)
    case text(text: String)
    case video(url: URL)
}

class CardView: UIView {
    
    // MARK: - Private attributes
    
    fileprivate var cardComponents: [CardComponent] = []
    fileprivate var stackView: UIStackView?
    
    // MARK: - Instance method
    
    class func from(card: Card) -> CardView {
        let cardView = CardView()
        cardView.stackView = UIStackView()
        cardView.stackView?.axis = .vertical
        cardView.stackView?.alignment = .center
        cardView.stackView?.distribution = .fill
        cardView.initializeView(with: card)
        return cardView
    }
}

private extension CardView {

    func initializeView(with card: Card) {
        guard let stackView = self.stackView else { return }
        self.addSubViewWithAutoLayout(
            view: stackView,
            withMargin: ViewMargin(top: 0, bottom: 0, left: 0, right: 0)
        )
        self.backgroundColor = .white
        switch card.type {
        case "imageText":
            guard
                let imageUrl = card.render["imageUrl"]?.toString(),
                let text = card.render["text"]?.toString(),
                let ratios = card.render["ratios"]?.toArray() as? [Float],
                let image = URL(string: imageUrl)
            else {
                return
            }
            if ratios.count == 2 {
                self.addImage(from: image, withPercentage: ratios[0])
                self.addText(text, withPercentage: ratios[1])
            }
            
        case "textImage":
            guard
                let imageUrl = card.render["imageUrl"]?.toString(),
                let text = card.render["text"]?.toString(),
                let ratios = card.render["ratios"]?.toArray() as? [Float],
                let image = URL(string: imageUrl)
            else {
                return
            }
            if ratios.count == 2 {
                self.addText(text, withPercentage: ratios[0])
                self.addImage(from: image, withPercentage: ratios[1])
            }
            
        case "richText":
            guard
                let richText = card.render["richText"]?.toString()
            else {
                return
            }
            self.addText(richText, withPercentage: 1.0)
        case "image":
            guard
                let imageUrl = card.render["imageUrl"]?.toString(),
                let image = URL(string: imageUrl)
            else {
                return
            }
            self.addImage(from: image, withPercentage: 1.0)
        default:
            return
        }
    }
    
    // MARK: - View methods
    
    func addImage(from url: URL, withPercentage percentage: Float) {
        let imageView = UIImageView()
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
        let url = URL(string: urlAddptedToSize)
        DispatchQueue.global().async {
            if let url = url {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        if let image = image {
                            imageView.image = image
                        }
                    }
                }
            }
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLayoutWidth(CGFloat(width))
        imageView.setLayoutHeight(CGFloat(height))
        self.stackView?.addArrangedSubview(imageView)
    }
    
    func addText(_ text: String, withPercentage percentage: Float) {
        let label = TopAlignedLabel(frame: CGRect.zero)
        label.numberOfLines = 0
        label.html = text
        label.setLayoutWidth(UIScreen.main.bounds.width * 0.9)
        // label.setLayoutHeight(UIScreen.main.bounds.height * CGFloat(percentage))
        // label.sizeToFit()
        self.stackView?.addArrangedSubview(label)
    }
}
