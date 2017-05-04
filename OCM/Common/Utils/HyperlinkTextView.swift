//
//  HyperlinkTextView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 11/04/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol HyperlinkTextViewDelegate: class {
    
    func didTapOnHyperlink(URL: URL)
}

class HyperlinkTextView: UITextView {
    
    // MARK: - Public properties
    
    var linkTapGestureRecognizer: UITapGestureRecognizer?
    weak var hyperlinkDelegate: HyperlinkTextViewDelegate?
    
    // MARK: - Initalizers 
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: - Custom initializer
    
    init(htmlText: String) {
        super.init(frame: .zero, textContainer: nil)
        setup()
        self.attributedText = NSAttributedString(fromHTML: htmlText)
    }
    
    // MARK: - Private helpers
    
    private func setup() {
        
        self.isEditable = false
        self.isSelectable = false
        self.isScrollEnabled = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLinkTapGestureRecognizer(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delaysTouchesBegan = false
        tapGestureRecognizer.delaysTouchesEnded = false
        self.addGestureRecognizer(tapGestureRecognizer)
        self.linkTapGestureRecognizer = tapGestureRecognizer
    }
    
    @objc private func handleLinkTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        
        let tapLocation = recognizer.location(in: self)
        
        // We need to get two positions since attributed links only apply to ranges with a length > 0
        var textPosition: UITextPosition?
        var nextTextPosition: UITextPosition?
        
        if let position = self.closestPosition(to: tapLocation) {
            if let aux = self.position(from: position, offset: 1) {
                textPosition = position
                nextTextPosition = aux
            } else {
                // Check if we're beyond the max length and go back by one
                if let aux = self.position(from: position, offset: -1) {
                    textPosition = aux
                    nextTextPosition = self.position(from: aux, offset: 1)
                }
            }
        }
        
        guard let fromPosition = textPosition,
            let toPosition = nextTextPosition,
            let textRange = self.textRange(from: fromPosition, to: toPosition) else {
                return
        }
        
        // Get the offset range of the character we tapped on
        let startOffset = self.offset(from: self.beginningOfDocument, to: textRange.start)
        let endOffset = self.offset(from: self.beginningOfDocument, to: textRange.end)
        let offsetRange = NSRange(location: startOffset, length: endOffset - startOffset)
        
        guard offsetRange.location != NSNotFound,
            offsetRange.length > 0,
            NSMaxRange(offsetRange) < self.attributedText.length else {
            return
        }
        
        // Grab the link from the String
        let attributedSubstring = self.attributedText.attributedSubstring(from: offsetRange)
        if let hyperlinkURL = attributedSubstring.attribute(NSLinkAttributeName, at: 0, effectiveRange: nil) as? NSURL,
            let hyperlink = hyperlinkURL.absoluteString,
            let URL = URL.init(string: hyperlink) {
            logInfo("User tapped on hyperlink: \(String(describing: hyperlinkURL.absoluteString))")
            self.hyperlinkDelegate?.didTapOnHyperlink(URL: URL)
        }
        
    }

}
