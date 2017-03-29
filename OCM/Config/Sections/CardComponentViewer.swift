//
//  CardComponentViewer.swift
//  OCM
//
//  Created by Carlos Vicente on 28/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol CardComponentViewer {
    func displayView() -> UIView
}

struct CardComponentImageViewer: CardComponentViewer {
    let cardComponent: CardComponentImage
    
    func displayView() -> UIView {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let percentage = cardComponent.percentage
        let width: Int = Int(UIScreen.main.bounds.width)
        let height: Int = Int(UIScreen.main.bounds.height * CGFloat(percentage))
        containerView.setLayoutWidth(UIScreen.main.bounds.width)
        containerView.setLayoutHeight(UIScreen.main.bounds.height * CGFloat(percentage))

        let url = cardComponent.imageUrl
        let imageView = UIImageView()
        let scaleFactor: Int = Int(UIScreen.main.scale)
        let margins = cardComponent.margins
        let viewMargin = ViewMargin(
            top: CGFloat(margins.top),
            bottom: CGFloat(margins.bottom),
            left: CGFloat(margins.left),
            right: CGFloat(margins.right)
        )

        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: url.absoluteString,
            width: width,
            height: height,
            scaleFactor: scaleFactor
        )
        let urlAddptedToSize = urlSizeComposserWrapper.urlCompossed
        imageView.imageFromURL(urlString: urlAddptedToSize, placeholder: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubViewWithAutoLayout(view: imageView, withMargin: viewMargin)
        
        return containerView
    }
}

struct CardComponentTextViewer: CardComponentViewer {
    let cardComponent: CardComponentText
    func displayView() -> UIView {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let percentage = cardComponent.percentage
        let margins = cardComponent.margins
        let viewMargin = ViewMargin(
            top: CGFloat(margins.top),
            bottom: CGFloat(margins.bottom),
            left: CGFloat(margins.left),
            right: CGFloat(margins.right)
        )
        containerView.setLayoutWidth(UIScreen.main.bounds.width)
        containerView.setLayoutHeight(UIScreen.main.bounds.height * CGFloat(percentage))
        
        let text = cardComponent.text
        let label = TopAlignedLabel(frame: CGRect.zero)
        label.html = text
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        
        containerView.addSubViewWithAutoLayout(view: label, withMargin: viewMargin)
        
        return containerView
    }
}
