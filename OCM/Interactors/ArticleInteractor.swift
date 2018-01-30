//
//  ArticleInteractor.swift
//  OCM
//
//  Created by Eduardo Parada on 6/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ArticleInteractorProtocol: class {
    func traceSectionLoadForArticle()
    func action(of element: Element, with info: Any)
}

protocol ArticleInteractorOutput: class {
    func showViewForAction(_ action: Action)
    func showAlert(_ message: String)
    func showVideo(_ video: Video, in player: VideoPlayerView?)
}

class ArticleInteractor: ArticleInteractorProtocol {
    
    var elementUrl: String?
    weak var output: ArticleInteractorOutput?
    weak var actionOutput: ActionOutput?
    let sectionInteractor: SectionInteractorProtocol
    let actionInteractor: ActionInteractorProtocol
    var ocm: OCM
    
    // MARK: - Initializer
    
    init(elementUrl: String?, sectionInteractor: SectionInteractorProtocol, actionInteractor: ActionInteractorProtocol, ocm: OCM) {
        self.elementUrl = elementUrl
        self.sectionInteractor = sectionInteractor
        self.actionInteractor = actionInteractor
        self.ocm = ocm
    }
    
    // MARK: - ArticleInteractorProtocol
    
    func traceSectionLoadForArticle() {
        guard
            let elementUrl = self.elementUrl,
            let section = self.sectionInteractor.sectionForActionWith(identifier: elementUrl)
            else {
                LogWarn("Element url or section is nil")
                return
        }
        self.ocm.eventDelegate?.sectionDidLoad(section)
    }
    
    func action(of element: Element, with info: Any) {
        if let customProperties = element.customProperties {
            self.ocm.customBehaviourDelegate?.contentNeedsValidation(
                for: customProperties,
                completion: { (succeed) in
                    if succeed {
                        self.performAction(of: element, with: info)
                    }
            })
        } else {
            self.performAction(of: element, with: info)
        }
    }
    
    // MARK: - Helpers
    
    private func performAction(of element: Element, with info: Any) {
        if element is ElementButton {
            self.performButtonAction(info)
        } else if element is ElementRichText {
            self.performRichTextAction(info)
        } else if element is ElementVideo {
            self.performVideoAction(info)
        }
    }

    private func performButtonAction(_ info: Any) {
        
        // Perform button's action
        if let action = info as? String {
            self.actionInteractor.action(forcingDownload: false, with: action) { action, _ in
                if var unwrappedAction = action {
                    if let elementUrl = unwrappedAction.elementUrl, !elementUrl.isEmpty {
                        self.ocm.eventDelegate?.userDidOpenContent(identifier: elementUrl, type: unwrappedAction.type ?? "")
                    } else if let slug = unwrappedAction.slug, !slug.isEmpty {
                        self.ocm.eventDelegate?.userDidOpenContent(identifier: slug, type: unwrappedAction.type ?? "")
                    }
                    
                    if  ActionViewer(action: unwrappedAction, ocm: self.ocm).view() != nil {
                        self.output?.showViewForAction(unwrappedAction)
                    } else {
                        guard var actionUpdate = action else {
                            logWarn("action is nil")
                            return
                        }
                        actionUpdate.output = self.actionOutput
                        ActionInteractor().execute(action: actionUpdate)
                    }
                } else {
                    self.output?.showAlert(Config.strings.internetConnectionRequired)
                }
            }
        }
    }
    
    private func performRichTextAction(_ info: Any) {
        // Open hyperlink's URL on web view
        if let URL = info as? URL {
            // Open on Safari VC
            self.ocm.wireframe.showBrowser(url: URL)
        }
    }
    
    private func performVideoAction(_ info: Any) {
        if let dictionary = info as? [String: Any], let video = dictionary["video"] as? Video {
            let player = dictionary["player"] as? VideoPlayerView
            self.output?.showVideo(video, in: player)
        }
    }

}
