//
//  ViewCustomizationType.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 09/01/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

/// Available customizations for displayed views
public enum ViewCustomizationType {
    case grayscale
    case darkLayer
    case lightLayer
    case imageOverlap(UIImage) // ???
    case errorMessage(String)
    case disabled
    case hidden // ???
    case none
}
