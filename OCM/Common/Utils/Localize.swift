//
//  Localize.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 31/3/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


func Localize(key: String) -> String {
    let message = NSLocalizedString(key, tableName: nil, bundle: NSBundle.OCM(), value: "", comment: "")
    
    return message
}
