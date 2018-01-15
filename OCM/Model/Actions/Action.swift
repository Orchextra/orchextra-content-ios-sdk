//
//  Action.swift
//  OCM
//
//  Created by Alejandro Jiménez on 19/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary

protocol ActionOut {
    func blockView()
    func unblockView()
}

extension ActionOut {
    func blockView() {}
    func unblockView() {}
}

protocol Action {
	static func action(from json: JSON) -> Action?
    static func preview(from json: JSON) -> Preview?
    
    var slug: String? { get set }
    var customProperties: [String: Any]? { get set } //!!!
    var preview: Preview? { get set }
    var shareInfo: ShareInfo? { get set }
    var output: ActionOut? { get set }
    var elementUrl: String? { get set }
    var type: String? { get set }
    var typeAction: ActionEnumType { get set }
    
    func updateLocalStorage()
}

// IMPLEMENTATION BY DEFAULT
extension Action {
    
    static func preview(from json: JSON) -> Preview? {
        
        var previewParsed: Preview?
        let share = shareInfo(from: json)
        if let previewJson = json["preview"] {
            previewParsed = PreviewFactory.preview(from: previewJson, shareInfo: share)
        }
        
        return previewParsed
    }
    
    static func shareInfo(from json: JSON) -> ShareInfo? {
        let url = json["share.url"]?.toString()
        let text = json["share.text"]?.toString()
        
        guard url != nil else { return nil }
        
        return ShareInfo(url: url, text: text)
    }
    
    
    func updateLocalStorage() {
        // Do Nothing
    }
}

class ActionFactory {
	
    class func action(from json: JSON, identifier: String?) -> Action? {
		let actions = [
			ActionWebview.action(from: json),
			ActionBrowser.action(from: json),
			ActionExternalBrowser.action(from: json),
			ActionContent.action(from: json),
			ActionArticle.action(from: json),
			ActionScanner.action(from: json),
			ActionVuforia.action(from: json),
			ActionCustomScheme.action(from: json),
			ActionVideo.action(from: json),
			ActionCard.action(from: json)
		]
		
		// Returns the last action that is not nil, or custom scheme is there is no actions
		var action =  actions.reduce(ActionBanner.action(from: json)) { $1 ?? $0 }
        action?.elementUrl = identifier
        action?.customProperties = json["customProperties"]?.toDictionary()
        return action
	}
	
}
