//
//  Section.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

public struct Section: Equatable {
    public let name: String
    public let slug: String
    public let elementUrl: String
    public let customProperties: [String: Any]? //!!!
    
    private let actionInteractor: ActionInteractor
    
    init(name: String, slug: String, elementUrl: String, customProperties: [String: Any]?) {
        self.name = name
        self.elementUrl = elementUrl
        self.slug = slug
        self.customProperties = customProperties //!!! 666
        
        self.actionInteractor = ActionInteractor(
            contentDataManager: .sharedDataManager,
            ocm: OCM.shared,
            actionScheduleManager: ActionScheduleManager.shared
        )
    }
    
    static public func parseSection(json: JSON) -> Section? {
        guard
            let name = json["sectionView.text"]?.toString(),
            let slug = json["slug"]?.toString(),
            let elementUrl = json["elementUrl"]?.toString(),
            let customProperties = json["segmentation"]?.toDictionary() else {
                logWarn("Mandatory field not found")
                return nil
        }
        
        return Section(
            name: name,
            slug: slug,
            elementUrl: elementUrl,
            customProperties: customProperties
        )
        
    }
    
    public func openAction(completion: @escaping (OrchextraViewController?) -> Void) {
        self.actionInteractor.action(forcingDownload: false, with: self.elementUrl) { action, _ in
            guard let action = action else { logWarn("actions is nil"); return }
            if let view = ActionViewer(action: action, ocm: OCM.shared).view() {
                completion(view)
            } else {
                ActionInteractor().run(action: action, viewController: nil)
                completion(nil)
            }
        }
    }
}

extension Section: Hashable {
    
    public var hashValue: Int {
        
        return name.hashValue ^ slug.hashValue ^ elementUrl.hashValue //!!!
        
    }

    public static func == (lhs: Section, rhs: Section) -> Bool {
        
        return lhs.hashValue == rhs.hashValue
    }
    
}
