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
        static let playIconPreviewView = UIImage(named: "iconPlay", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let colorPreviewView = UIImage(named: "color", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let shareButtonIconOpaque = UIImage(named: "preview_share_button_solid", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let shareButtonIconTransparent = UIImage(named: "preview_share_button_transparent", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let backButtonIconOpaque = UIImage(named: "content_back_button_solid", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let backButtonIconTransparent = UIImage(named: "content_back_button_transparent", in: Bundle.OCMBundle(), compatibleWith:nil)
    }
}
