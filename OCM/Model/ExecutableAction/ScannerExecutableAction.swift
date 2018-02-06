//
//  ScanExecutableAction.swift
//  OCM
//
//  Created by José Estela on 6/2/18.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

public class ScannerExecutableAction: ExecutableAction {
    
    public typealias ExecutableActionResponse = String
    
    func perform(_ completion: @escaping (ExecutableActionResponse) -> Void) {
        completion("123456")
    }
}
