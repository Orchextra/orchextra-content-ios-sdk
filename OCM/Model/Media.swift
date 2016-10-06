//
//  Media.swift
//  OCM
//
//  Created by Alejandro Jiménez Agudo on 4/4/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import Foundation
import GIGLibrary


struct Media {
    let url: String?
	
	static func media(from json: JSON) -> Media? {
		return Media(url: json["imageUrl"]?.toString())
	}
    
}
