//
//  CardComponentViewer.swift
//  OCM
//
//  Created by Carlos Vicente on 28/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import Gifu

protocol CardComponentViewer {
    func displayView() -> UIView
}

struct CardComponentImageViewer: CardComponentViewer {
    let cardComponent: CardComponentImage
    
    func displayView() -> UIView {
        let containerView = UIView(frame: .zero)
        let percentage = cardComponent.percentage
        let width: Int = Int(UIScreen.main.bounds.width)
        let height: Int = Int(UIScreen.main.bounds.height * CGFloat(percentage))
        
        containerView.set(autoLayoutOptions: [
            .width(UIScreen.main.bounds.width),
            .height(UIScreen.main.bounds.height * CGFloat(percentage), priority: 750)
        ])
        
        let url = cardComponent.imageUrl
        let imageView = GIFImageView()
        let scaleFactor: Int = Int(UIScreen.main.scale)
        let margins = cardComponent.margins
        
        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: url.absoluteString,
            width: width,
            height: height,
            scaleFactor: scaleFactor
        )
        
        let urlAddptedToSize = urlSizeComposserWrapper.urlCompossed
        
        if url.absoluteString.contains(".gif") {
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: url) else { return }
                DispatchQueue.main.async {
                    imageView.animate(withGIFData: imageData)
                }
            }
        } else {
            imageView.imageFromURL(urlString: urlAddptedToSize, placeholder: nil)
        }
        
        containerView.addSubview(
            view: imageView,
            settingAutoLayoutOptions: [
                .margin(
                    to: containerView,
                    top: CGFloat(margins.top),
                    bottom: CGFloat(margins.bottom),
                    left: CGFloat(margins.left),
                    right: CGFloat(margins.right)
                )
            ]
        )
        
        return containerView
    }
}

struct CardComponentTextViewer: CardComponentViewer {
    let cardComponent: CardComponentText
    func displayView() -> UIView {
        let containerView = UIView(frame: .zero)
        let percentage = cardComponent.percentage
        let margins = cardComponent.margins
        
        containerView.set(autoLayoutOptions: [
            .width(UIScreen.main.bounds.width),
            .height(UIScreen.main.bounds.height * CGFloat(percentage), priority: 750)
        ])
        
        let text = cardComponent.text
        let label = TopAlignedLabel(frame: CGRect.zero)
        label.attributedText = NSAttributedString(fromHTML: text)
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        
        containerView.addSubview(
            view: label,
            settingAutoLayoutOptions: [
                .margin(
                    to: containerView,
                    top: CGFloat(margins.top),
                    bottom: CGFloat(margins.bottom),
                    left: CGFloat(margins.left),
                    right: CGFloat(margins.right)
                )
            ]
        )
        
        return containerView
    }
}
