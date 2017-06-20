//
//  CompletionButton.swift
//  OCM
//
//  Created by José Estela on 19/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class CompletionTouchableView: UIView {
    
    // MARK: - Private attributes
    
    private var completion: (() -> Void)?
    
    // MARK: - Public methods
    
    func addAction(completion: @escaping (() -> Void)) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(action(_:)))
        tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(tap)
        self.completion = completion
    }
    
    // MARK: - Actions
    
    @objc private func action(_ sender: UIButton) {
        self.completion?()
    }
}
