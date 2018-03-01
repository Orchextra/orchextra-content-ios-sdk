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
    
    var customProperties: [String: Any]?

    weak var actionableDelegate: ActionableElementDelegate?
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

    var view: UIView?
    var button: LoadableButton?
    
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
        case .other:
            // Button with attributes
            if let title = json[ParsingConstants.ButtonElement.kText]?.toString(),
                let titleColorLiteral = json[ParsingConstants.ButtonElement.kTextColor]?.toString(),
                let titleColor = UIColor(fromHexString: titleColorLiteral),
                let backgroundColorLiteral = json[ParsingConstants.ButtonElement.kBackgroundColor]?.toString(),
                let backgroundColor = UIColor(fromHexString: backgroundColorLiteral) {
                return ElementButton(element: element, size: size, elementURL: elementURL, title: title, titleColor: titleColor, backgroundColor: backgroundColor)
            }
        }
        return nil
    }
    
    // MARK: - Element protocol
    
    func render() -> [UIView] {

        let button = self.createButton()
        self.button = button
        button.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        
        let view: UIView
        switch self.type {
        case .image:
            view = self.renderImageButton(button: button)
        default:
            view = self.renderDefaultButton(button: button)
        }
        self.view = view
        
        self.renderCustomization(button: button)
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(view)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Button"
    }
    
    // MARK: - Render helpers
    
    private func renderImageButton(button: UIButton) -> UIView {
        
        let view = UIView(frame: .zero)
        view.addSubview(button)
        
        button.set(autoLayoutOptions: [
            .margin(to: view, top: 20, bottom: 20),
            .centerX(to: view),
            .width(comparingTo: view, relation: .lessThanOrEqual, multiplier: 0.9)
        ])
        self.renderImage(button: button)
        
        return view
    }
    
    private func renderDefaultButton(button: UIButton) -> UIView {
    
        let view = UIView(frame: .zero)
        
        button.setTitle(self.title, for: .normal)
        button.setTitleColor(self.titleColor, for: .normal)
        button.backgroundColor = self.backgroundColor
        
        view.addSubview(button)
        
        button.set(autoLayoutOptions: [
            .margin(to: view, top: 20, bottom: 20, left: 20, right: 20),
            .centerX(to: view),
            .centerY(to: view)
        ])
        
        return view
    }
    
    private func renderImage(button: UIButton) {
        
        guard let imageURLString = self.backgroundImageURL else { logWarn("backgroundImageURL is nil"); return }
        ImageDownloadManager.shared.downloadImage(with: imageURLString, completion: { (image, _) in
            if let image = image {
                button.translatesAutoresizingMaskIntoConstraints = false
                button.contentMode = .scaleAspectFit
                button.setBackgroundImage(image, for: .normal)
                button.set(autoLayoutOptions: [
                    .aspectRatio(width: image.size.width, height: image.size.height)
                ])
            }
        })
    }
    
    private func renderCustomization(button: LoadableButton) {
        if let customProperties = self.customProperties {
            button.startLoading()
            let customizableContent = CustomizableContent(identifier: "\(Date().timeIntervalSince1970)_\(self.elementURL)", customProperties: customProperties, viewType: .buttonElement)
            OCM.shared.customBehaviourDelegate?.contentNeedsCustomization(customizableContent) { customizableContent in
                button.stopLoading()
                button.isEnabled = true
                button.alpha = 1
                customizableContent.customizations.forEach { customization in
                    switch customization {
                    case .disabled:
                        button.isEnabled = false
                        button.alpha = 0.3
                    case .hidden:
                        button.isHidden = true
                    case .viewLayer(let layer):
                        self.view?.addSubviewWithAutolayout(layer)
                    case .darkLayer(alpha: let alpha):
                        let layer = UIView()
                        layer.backgroundColor = .black
                        layer.alpha = alpha
                        self.view?.addSubviewWithAutolayout(layer)
                    case .lightLayer(alpha: let alpha):
                        let layer = UIView()
                        layer.backgroundColor = .white
                        layer.alpha = alpha
                        self.view?.addSubviewWithAutolayout(layer)
                    default:
                        LogWarn("This customization \(customization) hasn't any representation for the button content view.")
                    }
                }
            }
        }
    }
    
    // MARK: - Button selector
    
    @objc private func didTapOnButton() {
        self.actionableDelegate?.elementDidTap(self, with: self.elementURL)
    }
    
    // MARK: - UI helpers
    
    private func createButton() -> LoadableButton {
        
        let buttonInset: CGFloat
        switch self.size {
        case .small:
            buttonInset = 10
        case .medium:
            buttonInset = 20
        case .large:
            buttonInset = 30
        }
        let button = LoadableButton(frame: .zero)
        button.contentEdgeInsets = UIEdgeInsets(top: buttonInset, left: buttonInset, bottom: buttonInset, right: buttonInset)
        button.layer.cornerRadius = 5
        button.titleLabel?.numberOfLines = 0
        return button
    }
}

// MARK: - RefreshableElement

extension ElementButton: RefreshableElement {
    
    func update() {
        guard let button = self.button else { return }
        self.renderImage(button: button)
        self.renderCustomization(button: button)
    }
}
