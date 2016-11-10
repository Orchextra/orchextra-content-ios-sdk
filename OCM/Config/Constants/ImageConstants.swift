//
//  ImageConstants.swift
//  OCM
//
//  Created by Sergio López on 25/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

extension UIImage {
    struct OCM {
        static let swipe = UIImage(named: "swipe", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let previewGrading = UIImage(named: "preview_grading", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let previewSmallGrading = UIImage(named: "preview_small_grading", in: Bundle.OCMBundle(), compatibleWith:nil)
    }
}
