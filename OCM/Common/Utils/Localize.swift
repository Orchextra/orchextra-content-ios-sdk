//
//  Localize.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


func Localize(_ key: String) -> String {
    let message = NSLocalizedString(key, tableName: nil, bundle: Bundle.OCM(), value: "", comment: "")
    
    return message
}
