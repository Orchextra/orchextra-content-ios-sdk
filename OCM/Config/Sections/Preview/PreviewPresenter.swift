//
//  PreviewPresenter.swift
//  OCM
//
//  Created by Judith Medina on 24/10/16.
//  Copyright © 2016 Gigigo SL. All rights reserved.
//

import UIKit

protocol PPreview {
    func show(preview: UIView)
}

class PreviewPresenter {

    let preview: Preview
    var viewController: PPreview?

    init(preview: Preview) {
        self.preview = preview
    }
    
    // MARK: PUBLIC

    func viewIsReady() {
        guard let previewView = preview.display() else { return }
        viewController?.show(preview: previewView)
    }

    func userTappedPreview() {
        
    }
}
