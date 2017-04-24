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

        let button = UIButton(frame: CGRect.zero)
        button.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        switch self.type {
        case .image:
            if let backgroundImageURL = self.backgroundImageURL {
              self.renderBackgroundImage(url: backgroundImageURL, view: button)
            }
        default:
            button.setTitle(self.title, for: .normal)
            button.setTitleColor(self.titleColor, for: .normal)
            button.backgroundColor = self.backgroundColor
        }
        
        var elementArray: [UIView] = self.element.render()
        elementArray.append(button)
        return elementArray
    }
    
    func descriptionElement() -> String {
        return  self.element.descriptionElement() + "\n Button"
    }
    
    // MARK: - Image download
    
    private func renderBackgroundImage(url: String, view: UIView) {
        
        let imageView = UIImageView()
        let width: Int = Int(UIScreen.main.bounds.width)
        let scaleFactor: Int = Int(UIScreen.main.scale)
 
        view.addSubview(imageView)
        view.clipsToBounds = true
        
        let urlSizeComposserWrapper = UrlSizedComposserWrapper(
            urlString: url,
            width: width,
            height:nil,
            scaleFactor: scaleFactor
        )
        
        let urlAdaptedToSize = urlSizeComposserWrapper.urlCompossed
        let url = URL(string: urlAdaptedToSize)
        DispatchQueue.global().async {
            if let url = url {
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let data = data {
                        let image = UIImage(data: data)
                        if let image = image {
                            imageView.image = image
                            self.addSizeConstraints(view: view, size: image.size)
                            self.addMarginConstraints(subview: imageView, view: view)
                        }
                    }
                }
            }
        }        
    }
    
    // MARK: - Button selector
    
    @objc private func didTapOnButton() {
        self.delegate?.performAction(of: self, with: self.elementURL)
    }
    
    // MARK: - Autolayout helpers
    
    private func addSizeConstraints(size: ElementButtonSize) {
    
        switch size {
        case .small:
            break
        case .medium:
            break
        case .large:
            break
        }
    }
    
    private func addMarginConstraints(subview: UIView, view: UIView) {
        let views = ["subview": subview]
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[subview]-20-|", options: [], metrics: nil, views: views)
        let verticalConstrains = NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[subview]-20-|", options: [], metrics: nil, views: views)
        
        view.addConstraints(horizontalConstrains)
        view.addConstraints(verticalConstrains)
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
    
}
