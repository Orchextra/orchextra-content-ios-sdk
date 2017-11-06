//
//  ActionContent.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


class ActionContent: Action {
    
    var elementUrl: String?
    var output: ActionOut?
    internal var slug: String?
    internal var type: String?
    internal var preview: Preview?
    internal var shareInfo: ShareInfo?
    lazy internal var actionView: OrchextraViewController? = OCM.shared.wireframe.contentList(from: self.path)

	let path: String
	
    init(preview: Preview?, shareInfo: ShareInfo?, path: String, slug: String?) {
        self.preview = preview
        self.shareInfo = shareInfo
        self.path = path
        self.slug = slug
        self.type = ActionType.actionContent
    }
    
    func view() -> OrchextraViewController? {
        return self.actionView
    }
    
	static func action(from json: JSON) -> Action? {
		guard json["type"]?.toString() == ActionType.actionContent,
		let path = json["render.contentUrl"]?.toString()
            else { return nil }
		let slug = json["slug"]?.toString()
        return ActionContent(
            preview: preview(from: json),
            shareInfo: shareInfo(from: json),
            path: path,
            slug: slug
        )
	}
}
