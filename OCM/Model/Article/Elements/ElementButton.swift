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

class ElementButton: Element {
    
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

        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        
        let view: UIView
        switch self.type {
        case .image:
            view = self.renderImageButton(button: button)
        default:
            view = self.renderButton(button: button)
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
        
        guard let unwrappedURL = self.backgroundImageURL else {
            return UIView()
        }
        
        let imageView = UIImageView()
        let width: Int = Int(UIScreen.main.bounds.width)
        let scaleFactor: Int = Int(UIScreen.main.scale)
 
        button.addSubview(imageView)
        button.clipsToBounds = true
        
        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: unwrappedURL,
            width: width,
            height: nil,
            scaleFactor: scaleFactor
        )
        
        let urlAdaptedToSize = urlSizeComposserWrapper.urlCompossed
        let url = URL(string: urlAdaptedToSize)
        DispatchQueue.global().async {
            if let url = url {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        imageView.image = image
                        self.addVerticalMarginConstraints(view: button, subview: imageView)
                        self.addSizeConstraints(view: button, size: image.size)
                    }
                }
            }
        }
        return button
    }
    
    private func renderButton(button: UIButton) -> UIView {
    
        let view = UIView(frame: .zero)
        button.setTitle(self.title, for: .normal)
        button.setTitleColor(self.titleColor, for: .normal)
        button.backgroundColor = self.backgroundColor
        self.addSizeConstraints(button: button, size: self.size)
        
        view.addSubview(button)
        self.addWidthConstraint(view: view)
        self.addVerticalMarginConstraints(view: view, subview: button)
        self.addCenterConstraints(view: view, subview: button)
        
        return view
    }
    
    // MARK: - Button selector
    
    @objc private func didTapOnButton() {
    
        print("Tapped on button!")
    }
    
    // MARK: - Autolayout helpers
    
    private func addSizeConstraints(button: UIButton, size: ElementButtonSize) {
    
        button.translatesAutoresizingMaskIntoConstraints = false
        let titleSize = button.titleLabel?.sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude)) ?? CGSize.zero
        var buttonInsets: CGFloat
        switch size {
        case .small:
            buttonInsets = 10
            break
        case .medium:
            buttonInsets = 30
            break
        case .large:
            buttonInsets = 40
            break
        }
        let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: titleSize.width + buttonInsets)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 1.0, constant: titleSize.height + buttonInsets)
        button.addConstraints([widthConstraint, heightConstraint])
    }
    
    private func addSizeConstraints(view: UIView, size: CGSize) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let Hconstraint = NSLayoutConstraint(
            item: view,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.height,
            multiplier: size.width / size.height,
            constant: 0)
        view.addConstraints([Hconstraint])
    }
    
    private func addWidthConstraint(view: UIView) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let Wconstraint = NSLayoutConstraint(item: view,
                                             attribute: NSLayoutAttribute.width,
                                             relatedBy: NSLayoutRelation.equal,
                                             toItem: nil,
                                             attribute: NSLayoutAttribute.notAnAttribute,
                                             multiplier: 1.0,
                                             constant: UIScreen.main.bounds.width)
        
        view.addConstraint(Wconstraint)
    }
    
    private func addCenterConstraints(view: UIView, subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = NSLayoutConstraint(item: subview, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: subview, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        view.addConstraints([centerXConstraint, centerYConstraint])
    }
    
    private func addVerticalMarginConstraints(view: UIView, subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[subview]-20-|", options: [], metrics: nil, views: ["subview": subview])
        view.addConstraints(verticalConstraints)
    }
    
}
