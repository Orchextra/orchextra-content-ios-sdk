//
//  BackgroundColorHour.swift
//  Ferring
//
//  Created by eduardo parada pardo on 4/10/18.
//  Copyright © 2018 Eduardo Parada. All rights reserved.
//

import Foundation
import GIGLibrary

enum Tonality: String {
    case dark
    case light
}

enum BackgroundColors {
    case morning
    case morningDark
    case afternoon
    case afternoonDark
    case evening
    case eveningDark
    case night
    case nightDark
}

// swiftlint:disable cyclomatic_complexity

//@IBDesignable
class BackgroundColorHour: UIView {
    
    @IBInspectable var tonalityName: String? {
        willSet {
            if let newTonality = Tonality(rawValue: newValue ?? "") {
                tonality = newTonality
            }
        }
    }
    
    var tonality: Tonality?
    var gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateSize() {
        self.layoutIfNeeded()
    }
    
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loadGradient()
    }
    
    // MARK: - Private method
    
    private func loadGradient() {
        if self.gradientLayer.bounds != self.bounds {
            _ = self.layer.sublayers?.firstIndex(where: { $0 == self.gradientLayer }).map { self.layer.sublayers?.remove(at: $0) }
            self.clipsToBounds = true
            self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
            self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.2)
            self.gradientLayer.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: self.bounds.size.width, height: self.bounds.size.height)
            )
            self.gradientLayer.colors = self.getColor()
            self.layer.addSublayer(self.gradientLayer)
        }
    }
    
    private func getColor() -> [CGColor] {
        let background = self.getCurrentBackground()
        switch background {
        case .morning:
            return [
                self.getCGColor(color: "#d2e8f4"),
                self.getCGColor(color: "#f1f3ec")
            ]
        case .morningDark:
            return [
                self.getCGColor(color: "#68b1d8"),
                self.getCGColor(color: "#dad9b2")
            ]
            
        case .afternoon:
            return [
                self.getCGColor(color: "#cddfdc"),
                self.getCGColor(color: "#f0f6dd")
            ]
        case .afternoonDark:
            return [
                self.getCGColor(color: "#599288"),
                self.getCGColor(color: "#d0e18e")
            ]
            
        case .evening:
            return [
                self.getCGColor(color: "#d1cddf"),
                self.getCGColor(color: "#f1e8db")
            ]
        case .eveningDark:
            return [
                self.getCGColor(color: "#655992"),
                self.getCGColor(color: "#ceb186")
            ]
            
        case .night:
            return [
                self.getCGColor(color: "#b9c8d6"),
                self.getCGColor(color: "#d8e6f6")
            ]
        case .nightDark:
            return [
                self.getCGColor(color: "#144877"),
                self.getCGColor(color: "#deecfc")
            ]
        }
    }
    
    private func getCurrentBackground() -> BackgroundColors {
        guard let tonality = self.tonality else { LogWarn("Tonality is nil"); return .morning }
        let hour = Calendar.current.component(.hour, from: Date())
        switch tonality {
        case .dark:
            if hour <= 7 {
                return .nightDark
            } else if hour <= 12 {
                return .morningDark
            } else if hour <= 17 {
                return .afternoonDark
            } else if hour <= 20 {
                return .eveningDark
            } else if hour <= 24 {
                return .nightDark
            }
        case .light:
            if hour <= 7 {
                return .night
            } else if hour <= 12 {
                return .morning
            } else if hour <= 17 {
                return .afternoon
            } else if hour <= 20 {
                return .evening
            } else if hour <= 24 {
                return .night
            }
        }
        
        return .morning
    }
    
    private func getCGColor(color: String) -> CGColor {
        guard let uiColor = UIColor(fromHexString: color) else {
            return UIColor.white.cgColor
        }
        return uiColor.cgColor
    }
}

// swiftlint:enable cyclomatic_complexity
