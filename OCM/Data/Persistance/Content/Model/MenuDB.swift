//
//  MenuDB+CoreDataClass.swift
//  OCM
//
//  Created by José Estela on 7/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import CoreData

@objc(MenuDB)
public class MenuDB: NSManagedObject {

    // MARK: - Transformation method
    
    /// Transform a MenuDB into a Menu model
    ///
    /// - Returns: The menu if all values are correctly retrieve from db
    func toMenu() -> Menu? {
        guard let identifier = self.identifier, let sectionsDB = self.sections?.allObjects as? [SectionDB] else { return nil }
        let sections = sectionsDB
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .flatMap({ $0.toSection() })
        return Menu(slug: identifier, sections: sections)
    }
}
