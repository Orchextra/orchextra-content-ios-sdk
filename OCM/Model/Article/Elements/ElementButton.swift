//
//  ElementButton.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 20/04/2017.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

enum ElementButtonSize: String {
    case small
    case medium
    case large
}
enum ElementButtonType: String {
    case image
    case other = "default"
}

class ElementButton: Element, ActionableElement {
    
    weak var delegate: ActionableElementDelegate?
    var element: Element
    var size: ElementButtonSize
    var elementURL: String
    var type: ElementButtonType
    // Default type attributes
    var title: String?
    var titleColor: UIColor?
    var backgroundColor: UIColor?
    // Image type attributes
    var backgroundImageURL: String?

    // MARK: - Initializers
    
    init(element: Element, size: ElementButtonSize, elementURL: String, title: String?, titleColor: UIColor?, backgroundColor: UIColor?) {
        self.type = .other
        self.element = element
        self.size = size
        self.elementURL = elementURL
        self.title = title
        self.titleColor = titleColor
        self.backgroundColor = backgroundColor
    }
    
    init(element: Element, size: ElementButtonSize, elementURL: String, backgroundImageURL: String?) {
        self.type = .image
        self.element = element
        self.size = size
        self.elementURL = elementURL
        self.backgroundImageURL = backgroundImageURL
    }
    
    // MARK: - Public methods
    
    static func parseRender(from json: JSON, element: Element) -> Element? {
        
        guard let elementURL = json[ParsingConstants.ButtonElement.kElementURL]?.toString(),
            let typeLiteral = json[ParsingConstants.ButtonElement.kType]?.toString(),
            let type = ElementButtonType(rawValue: typeLiteral),
            let sizeLiteral = json[ParsingConstants.ButtonElement.kSize]?.toString(),
            let size = ElementButtonSize(rawValue: sizeLiteral) else {
                logWarn("Error Parsing Button")
                return nil
        }
        
        switch type {
        case .image:
            // Button with image
            if let backgroundImageURL = json[ParsingConstants.ButtonElement.kBackgroundImageURL]?.toString() {
                return ElementButton(element: element, size: size, elementURL: elementURL, backgroundImageURL: backgroundImageURL)
            }
            break
        case .other:
            // Button with attributes
            if let title = json[ParsingConstants.ButtonElement.kText]?.toString(),
                let titleColorLiteral = json[ParsingConstants.ButtonElement.kTextColor]?.toString(),
                let titleColor = UIColor(fromHexString: titleColorLiteral),
                let backgroundColorLiteral = json[ParsingConstants.ButtonElement.kBackgroundColor]?.toString(),
                let backgroundColor = UIColor(fromHexString: backgroundColorLiteral) {
                return ElementButton(element: element, size: size, elementURL: elementURL, title: title, titleColor: titleColor, backgroundColor: backgroundColor)
            }
            break
        }

        return nil
    }
    
    // MARK: - Element protocol
    
    func render() -> [UIView] {

        let button = self.button()
        button.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        
        let view: UIView
        switch self.type {
        case .image:
            view = self.renderImageButton(button: button)
        default:
            view = self.renderDefaultButton(button: button)
        }
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Button"
    }
    
    // MARK: - Render helpers
    
    private func renderImageButton(button: UIButton) -> UIView {
        
        // TODO: Download image and add constraints
        // guard let _ = self.backgroundImageURL else {
        //    return UIView()
        // }
        return button
    }
    
    private func renderDefaultButton(button: UIButton) -> UIView {
    
        let view = UIView(frame: .zero)
        
        button.setTitle(self.title, for: .normal)
        button.setTitleColor(self.titleColor, for: .normal)
        button.backgroundColor = self.backgroundColor
        
        view.addSubview(button)
        self.addMargins(button, to: view)
        self.center(button, in: view)
        
        return view
    }
    
    // MARK: - Button selector
    
    @objc private func didTapOnButton() {
        self.delegate?.performAction(of: self, with: self.elementURL)
    }
    
    // MARK: - UI helpers
    
    private func button() -> UIButton {
        
        let buttonInset: CGFloat
        switch self.size {
        case .small:
            buttonInset = 10
            break
        case .medium:
            buttonInset = 20
            break
        case .large:
            buttonInset = 30
            break
        }
        let button = UIButton(frame: .zero)
        button.contentEdgeInsets = UIEdgeInsets(top: buttonInset, left: buttonInset, bottom: buttonInset, right: buttonInset)
        button.layer.cornerRadius = 5
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.lineBreakMode = .byClipping
        return button
    }
    
    // MARK: - Autolayout helpers
    
    private func center(_ button: UIButton, in view: UIView) {
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        view.addConstraints([centerXConstraint, centerYConstraint])
    }
    
    private func addMargins(_ button: UIButton, to view: UIView) {
        
        let key = "button"
        let views = [key: button]
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[\(key)]-20-|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[\(key)]-20-|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: views)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(verticalConstraints)
        view.addConstraints(horizontalConstraints)
    }
    
}
