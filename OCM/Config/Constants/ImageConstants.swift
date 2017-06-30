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
        static let previewGrading = UIImage(named: "preview_grading", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let previewSmallGrading = UIImage(named: "preview_small_grading", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let previewScrollDownIcon = UIImage(named: "preview_scroll_arrow_icon", in: Bundle.OCMBundle(), compatibleWith: nil)
        static let playIconPreviewView = UIImage(named: "iconPlay", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let shareButtonIcon = UIImage(named: "content_share_button", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let backButtonIcon = UIImage(named: "content_back_button", in: Bundle.OCMBundle(), compatibleWith:nil)
        static let cachedIcon = UIImage(named: "bolt", in: Bundle.OCMBundle(), compatibleWith:nil)
    }
}
