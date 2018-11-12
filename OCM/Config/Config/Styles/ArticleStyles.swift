//
//  ArticleStyles.swift
//  OCM
//
//  Created by Carlos Vicente on 25/10/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit

public class ArticleStyles {
    
    // MARK: - Public properties
    
    /**
     Text color for the content information.
     */
    public var richtextColor: UIColor
    
    /**
     Text font for the rich text content.
     */
    public var richtextFont: UIFont
    
    /**
     Text font for the header content.
     */
    public var headerFont: UIFont
    
    /**
     Text color for the header text information.
     */
    public var headerTextColor: UIColor
    
    /**
     Text background view for the article.
     */
    public var backgroundView: BackgroundViewFactory?
    
    public init() {
        self.richtextColor = UIColor.black
        self.richtextFont = UIFont.systemFont(ofSize: 16)
        self.headerFont = UIFont(name: "Gotham-Medium", size: 28) ?? UIFont.systemFont(ofSize: 28)
        self.headerTextColor = UIColor(fromRed: 71, green: 71, blue: 71)
    }
    
}
