//
//  CompletionButton.swift
//  OCM
//
//  Created by José Estela on 19/6/17.
//  Copyright © 2017 Gigigo SL. All rights reserved.
//

import Foundation
import UIKit

class CompletionButton: UIButton {
    
    // MARK: - Private attributes
    
    private var completion: (() -> Void)?
    
    // MARK: - Init methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
    }
    
    // MARK: - Public methods
    
    func addAction(completion: @escaping (() -> Void)) {
        self.completion = completion
    }
    
    // MARK: - Actions
    
    @objc private func action(_ sender: UIButton) {
        self.completion?()
    }
}
