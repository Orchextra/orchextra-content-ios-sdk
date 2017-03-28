//
//  PvewiView.swift
//  OCM
//
//  Created by José Estela on 17/3/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

// MARK: - PreviewViewDelegate

protocol PreviewViewDelegate: class {
    func previewViewDidSelectShareButton()
}

// MARK: - PreviewView Protocol

protocol PreviewView: class {
    weak var delegate: PreviewViewDelegate? { get set }
    func previewDidAppear()
    func previewDidScroll(scroll: UIScrollView)
    func imagePreview() -> UIImageView?
    func show() -> UIView
    func previewWillDissapear() //!!!
}
