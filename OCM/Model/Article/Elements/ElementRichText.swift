//
//  ElementRichText.swift
//  OCM
//
//  Created by Judith Medina on 18/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class ElementRichText: Element, ActionableElement, HyperlinkTextViewDelegate {
    
    var customProperties: [String: Any]?
    
    // MARK: - Public properties 
    
    var element: Element
    var htmlText: String
    weak var actionableDelegate: ActionableElementDelegate?
    
    // MARK: - Initializer
    
    init(element: Element, htmlText: String) {
        self.element = element
        self.htmlText = htmlText
    }
    
    // MARK: - Public methods
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let htmlText = json[ParsingConstants.RichTextElement.kText]?.toString()
            else {
                logError(NSError(message: ("Error Parsing Rich Text")))
                return nil}
        
        return ElementRichText(element: element, htmlText: htmlText)
    }
    
    // MARK: - Element
    
    func render() -> [UIView] {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .white
        
        let textView = HyperlinkTextView(htmlText: htmlText, font: UIFont.systemFont(ofSize: 16))
        textView.hyperlinkDelegate = self
        view.addSubview(textView)
        
        self.addConstrainst(toLabel: textView, view: view)
        self.addConstraints(view: view)

        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Rich Text"
    }
    
    // MARK: - HyperlinkTextViewDelegate
    
    func didTapOnHyperlink(URL: URL) {
        self.actionableDelegate?.elementDidTap(self, with: URL)
    }
    
    // MARK: - Private helpers
    
    private func addConstraints(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: view,
                                             attribute: .width,
                                             relatedBy: .equal,
                                             toItem: nil,
                                             attribute: .notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        view.addConstraints([widthConstraint])
    }
    
    private func addConstrainst(toLabel label: UIView, view: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[label]-8-|", options: [], metrics: nil, views: ["label": label])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: ["label": label])

        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
}
