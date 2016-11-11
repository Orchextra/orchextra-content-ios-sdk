//
//  Action.swift
//  OCM
//
//  Created by Alejandro Jiménez on 19/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


protocol Action {
	static func action(from json: JSON) -> Action?
    static func preview(from json: JSON) -> Preview?

    var preview: Preview? {get set}
	func view() -> OrchextraViewController?
    func run(viewController: UIViewController?)
    func executable()
}

// IMPLEMENTATION BY DEFAULT
extension Action {

    static func preview(from json: JSON) -> Preview? {
        
        var previewParsed: Preview?

        if let previewJson = json["preview"] {
            previewParsed = PreviewImageText.parsePreview(json: previewJson)
        }
        
        return previewParsed
    }
    
	func view() -> OrchextraViewController? { return nil }
    
    func run(viewController: UIViewController? = nil) { }
    
    func executable() { }
}


class ActionFactory {
	
	class func action(from json: JSON) -> Action? {
		let actions = [
			ActionCoupons.action(from: json),
			ActionCouponDetail.action(from: json),
			ActionWebview.action(from: json),
			ActionBrowser.action(from: json),
			ActionContent.action(from: json),
			ActionArticle.action(from: json),
			ActionScanner.action(from: json),
			ActionVuforia.action(from: json),
			ActionCustomScheme.action(from: json)
		]
		
		// Returns the last action that is not nil, or custom scheme is there is no actions
		return actions.reduce(ActionBanner.action(from: json)) { $1 ?? $0 }
	}
	
}
