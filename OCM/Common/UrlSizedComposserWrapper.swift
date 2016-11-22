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
    let width: Int
    let height: Int
    let scaleFactor: Int
    
    var urlCompossed: String {
        var urlComponents = URLComponents(string: self.urlString)
        let cellHeightScaled = Int(self.height * self.scaleFactor)
        let cellWidthScaled = Int(self.width * self.scaleFactor)
        let heightQueryItem = URLQueryItem(name: "h", value: String(cellHeightScaled))
        let widthtQueryItem = URLQueryItem(name: "w", value: String(cellWidthScaled))
        urlComponents?.queryItems = [heightQueryItem, widthtQueryItem]        
        return (urlComponents?.url?.absoluteString) ?? ""
    }
}
