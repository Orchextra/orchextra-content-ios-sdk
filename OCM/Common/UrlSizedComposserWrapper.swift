//
//  UrlSizedComposserWrapper.swift
//  OCM
//
//  Created by Carlos Vicente on 22/11/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation

struct UrlSizedComposserWrapper {
    
    let urlString: String
    let width: Int?
    let height: Int?
    let scaleFactor: Int
    
    var urlCompossed: String {
        var queryItems: [URLQueryItem] = [URLQueryItem]()
        var urlComponents = URLComponents(string: self.urlString)
        let cellHeightScaled = Int(self.height ?? 0 * self.scaleFactor)
        let cellWidthScaled = Int(self.width ?? 0 * self.scaleFactor)
        
        if cellHeightScaled > 0 {
            let heightQueryItem = URLQueryItem(name: "h", value: String(cellHeightScaled))
            queryItems.append(heightQueryItem)
        }
        
        if cellWidthScaled > 0 {
            let widthtQueryItem = URLQueryItem(name: "w", value: String(cellWidthScaled))
            queryItems.append(widthtQueryItem)
        }
        
        urlComponents?.queryItems = queryItems
        return (urlComponents?.url?.absoluteString) ?? ""
    }
}
