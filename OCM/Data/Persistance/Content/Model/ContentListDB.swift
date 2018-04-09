//
//  ContentListDB+CoreDataClass.swift
//  OCM
//
//  Created by José Estela on 15/11/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//
//

import Foundation
import CoreData
import GIGLibrary

@objc(ContentListDB)
public class ContentListDB: NSManagedObject {
    
    // MARK: - Transformation
    
    /// Transform a ContentListDB into a Content List model
    ///
    /// - Parameter elements: override of elements
    /// - Returns: The contentlist if all values are correctly retrieve from db
    func toContentList(with elements: [ElementDB]? = nil) -> ContentList? {
        guard
            let layout = self.layout,
            let layoutJSON = JSON.fromString(layout)
        else {
            return nil
        }
        let contents = elements ?? self.elements?.compactMap({ $0 as? ElementDB })
        return ContentList(
            contents: contents?.sorted(by: { $0.orderIndex < $1.orderIndex }).compactMap({ $0.toContent() }) ?? [],
            layout: LayoutFactory.layout(forJSON: layoutJSON),
            expiredAt: self.expirationDate as Date?,
            contentVersion: self.contentVersion
        )
    }
}
