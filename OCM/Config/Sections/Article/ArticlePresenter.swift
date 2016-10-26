//
//  ArticlePresenter.swift
//  OCM
//
//  Created by Judith Medina on 19/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol PArticleVC {
    func show(elements: [UIView])
}

class ArticlePresenter: NSObject {
    
    let article: Article
    var viewController: PArticleVC?
    
    init(article: Article) {
        self.article = article
    }
    
    func viewIsReady() {
        
        guard let elementsArticle = self.article.elements else {
            print("There are not elements in this article.")
            return
        }
        
        print(elementsArticle)
        self.viewController?.show(elements: elementsArticle)
    }
    
}
