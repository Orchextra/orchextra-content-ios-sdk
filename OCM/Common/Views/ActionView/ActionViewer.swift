//
//  ActionViewer.swift
//  OCM
//
//  Created by Eduardo Parada on 16/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import UIKit

protocol ActionViewer {
    var action: Action {get set}
    var ocm: OCM {get set}
    
    func view() -> OrchextraViewController?
}


struct ActionVideoViewer: ActionViewer {
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        guard let action =  action as? ActionVideo else { logWarn("action doesn't is a ActionVideo"); return nil }
        
        switch action.video.format {
        case .youtube:
            return self.ocm.wireframe.loadYoutubeVC(with: action.video.source)
        default:
            return self.ocm.wireframe.loadVideoPlayerVC(with: action.video)
        }
    }
}

struct ActionCardViewer: ActionViewer {
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        guard let action =  action as? ActionCard else { logWarn("action doesn't is a ActionCard"); return nil }
        return self.ocm.wireframe.loadCards(with: action.cards)
    }
}

class ActionWebviewViewer: ActionViewer {
    var ocm: OCM
    var action: Action
    
    init(ocm: OCM, action: Action) {
        self.ocm = ocm
        self.action = action
    }
        
    func view() -> OrchextraViewController? {  // TODO EDU, problema, tengo que ver ocmo informar al action que tiene q actualizar el local storage
        guard let actionWebview = self.action as? ActionWebview else { logWarn("Action doesn't is a ActionWebview"); return nil }
       // actionWebview.resetLocalStorage = false
        return self.ocm.wireframe.loadWebView(with: actionWebview)
    }
}

struct ActionBrowserViewer: ActionViewer {  // TODO EDU NOHITNG este se puede borrar
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        return nil
    }
}

struct ActionExternalBrowerViewer: ActionViewer { // TODO EDU NOHITNG este se puede borrar
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        return nil
    }
}

struct ActionBannerViewer: ActionViewer { // TODO EDU NOHITNG este se puede borrar
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        return nil
    }
}

struct ActionCustomSchemeViewer: ActionViewer { // TODO EDU NOHITNG este se puede borrar
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        return nil
    }
}

struct ActionScannerViewer: ActionViewer { // TODO EDU NOHITNG este se puede borrar
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        return nil
    }
}

struct ActionVuforiaViewer: ActionViewer { // TODO EDU NOHITNG este se puede borrar
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        return nil
    }
}

struct ActionArticleViewer: ActionViewer {
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        guard let actionArticle = self.action as? ActionArticle else { logWarn("Action doesn't is a ActionArticle"); return nil }
        return self.ocm.wireframe.loadArticle(
            with: actionArticle.article,
            elementUrl: self.action.elementUrl
        )
    }
}

struct ActionContentViewer: ActionViewer {
    var ocm: OCM
    var action: Action
    
    func view() -> OrchextraViewController? {
        guard let actionContent = self.action as? ActionContent else { logWarn("Action doesn't is a ActionContent"); return nil }
        return self.ocm.wireframe.loadContentList(from: actionContent.path)
    }
}


