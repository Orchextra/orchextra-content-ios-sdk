//
//  NewContentView.swift
//  OCM
//
//  Created by Jerilyn Goncalves on 15/02/2018.
//  Copyright © 2018 Gigigo SL. All rights reserved.
//

import UIKit
import GIGLibrary

class NewContentView {
    
    class func instantiate() -> UIView {
        let newContentButton = UIButton()
        newContentButton.setTitle("NEW POST", for: .normal)
        newContentButton.setTitleColor(.blue, for: .normal)
        newContentButton.setImage(#imageLiteral(resourceName: "new_content_arrow"), for: .normal)
        newContentButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        newContentButton.backgroundColor = .white
        newContentButton.setCornerRadius(15)
        newContentButton.imageView?.tintColor = .blue
        newContentButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        newContentButton.layer.shadowColor = UIColor.black.cgColor
        newContentButton.layer.shadowRadius = 10.0
        newContentButton.layer.shadowOpacity = 0.5
        newContentButton.layer.masksToBounds = false
        newContentButton.isUserInteractionEnabled = false
        gig_constrain_height(newContentButton, 30)
        gig_constrain_width(newContentButton, 150)
        return newContentButton
    }
}
