//
//  ActionViewer.swift
//  OCM
//
//  Created by Eduardo Parada on 16/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol ActionViewer {
    func displayView() -> UIView
}

struct ActionWebviewViewer: ActionViewer {
    
    func displayView() -> UIView {
        return UIView()
    }
}

struct ActionBrowserViewer: ActionViewer {
    
    func displayView() -> UIView {
        return UIView()
    }
}

struct ActionExternalBrowerViewer: ActionViewer {
    
    func displayView() -> UIView {
        return UIView()
    }
}

struct ActionArticleViewer: ActionViewer {
    
    func displayView() -> UIView {
        
        lazy internal var actionView: OrchextraViewController? = OCM.shared.wireframe.loadArticle(with: self.article, elementUrl: self.elementUrl)
        
        return UIView()
    }
}



