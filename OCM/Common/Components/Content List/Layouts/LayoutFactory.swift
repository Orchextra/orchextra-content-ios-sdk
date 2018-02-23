//
//  LayoutFactory.swift
//  OCM
//
//  Created by Sergio López on 14/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

struct LayoutFactory {
    
    // MARK: - PUBLIC
    
    static func layout(forJSON json: JSON) -> Layout {
        
        let layoutType: LayoutType = json["name"]?.toString() == "carousel" ? .carousel : .mosaic
        
        switch layoutType {
        case .mosaic:
            guard let patternJSON = json["pattern"] else {
                let defaultSizePattern = [CGSize(width: 1, height: 1)]
                return MosaicLayout(sizePattern: defaultSizePattern)
            }
            let pattern = self.pattern(forJSON: patternJSON)
            var array: [CGSize] = []
            for i in 0...10 {
                array.append(CGSize(width: 1, height: 1))
            }
            return MosaicLayout(sizePattern: array)
        case .carousel:
            return CarouselLayout()
        }
    }
    
    // MARK: - PRIVATE
    
    private static  func pattern(forJSON json: JSON) -> [CGSize] {
        
        let sizes = json.flatMap { (patternJson) -> CGSize? in
            
            guard let rows = patternJson["row"]?.toInt() else { return nil }
            guard let columns = patternJson["column"]?.toInt() else { return nil }

            return CGSize(width: CGFloat(rows), height: CGFloat(columns))
        }
        return sizes
    }
}
