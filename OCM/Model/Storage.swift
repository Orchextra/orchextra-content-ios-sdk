//
//  Storage.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 5/8/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation


/// In memory model cache
class Storage {
	
	static let shared = Storage()
	
	var widgetList: [Widget]?
}
